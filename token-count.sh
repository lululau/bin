#!/bin/bash

# Token 计算脚本 - 支持中英文混合文本的离线估算
# 使用方法:
#   echo "你的文本" | ./token-count.sh
#   ./token-count.sh 文件1.txt 文件2.txt
#   ./token-count.sh --help
#   ./token-count.sh --json 文件.txt

# 显示帮助信息
show_help() {
    cat << 'EOF'
Token 计算脚本 - 支持中英文混合文本的离线估算

使用方法:
  echo "文本" | ./token-count.sh               从标准输入读取文本
  ./token-count.sh [选项] [文件...]            从指定文件读取文本（支持多个文件）

选项:
  -h, --help                                  显示此帮助信息
  -j, --json                                  以 JSON 格式输出统计信息

示例:
  echo "Hello 世界 123!" | ./token-count.sh
  ./token-count.sh file1.txt file2.txt
  ./token-count.sh --json document.txt
  cat document.txt | ./token-count.sh --json
EOF
}

# 函数：计算英文单词的 token 数量
calculate_english_tokens() {
    local text="$1"
    local word_count=$(echo "$text" | grep -oE '\b[a-zA-Z]+\b' | wc -l | tr -d ' ')

    # 英文单词平均每个单词约 0.75-1 个 token
    # 这里使用保守估计：0.85 tokens per word
    echo "scale=2; $word_count * 0.85" | bc -l
}

# 函数：计算中文字符的 token 数量
calculate_chinese_tokens() {
    local text="$1"
    # 使用 Perl 统计中文字符总数，保存到变量
    local char_count=$(echo "$text" | perl -C -e 'my $text = join("", <>); my $count = () = $text =~ /\p{Han}/g; print $count')

    # 中文字符平均每个字符约 1.5 个 token
    echo "scale=2; $char_count * 1.5" | bc -l
}

# 函数：计算标点符号和数字的 token 数量
calculate_punctuation_numbers_tokens() {
    local text="$1"
    # 使用 Perl 统计标点符号和数字总数
    local count=$(echo "$text" | perl -C -e 'my $text = join("", <>); my $count = () = $text =~ /[^\p{Latin}\p{Han}\s]/g; print $count')

    # 标点符号和数字每个算 1 个 token
    echo "$count"
}

# 主函数：计算总 token 数量
calculate_total_tokens() {
    local text="$1"
    local english_tokens=$(calculate_english_tokens "$text")
    local chinese_tokens=$(calculate_chinese_tokens "$text")
    local punctuation_tokens=$(calculate_punctuation_numbers_tokens "$text")

    # 总 token 数量向上取整
    local total=$(echo "scale=2; $english_tokens + $chinese_tokens + $punctuation_tokens" | bc -l)
    echo "$total" | awk '{print int($1 + 0.9999)}'
}

# 分析文本并返回所有统计信息
analyze_text() {
    local text="$1"
    local source="$2"

    local total_tokens=$(calculate_total_tokens "$text")
    local english_tokens=$(calculate_english_tokens "$text")
    local chinese_tokens=$(calculate_chinese_tokens "$text")
    local punctuation_tokens=$(calculate_punctuation_numbers_tokens "$text")

    echo "$total_tokens|$english_tokens|$chinese_tokens|$punctuation_tokens|$source"
}

# 解析命令行参数
files=()
output_format="text"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -j|--json)
            output_format="json"
            shift
            ;;
        -*)
            echo "错误: 未知选项 $1" >&2
            echo "使用 ./token-count.sh --help 查看帮助信息" >&2
            exit 1
            ;;
        *)
            files+=("$1")
            shift
            ;;
    esac
done

# 收集所有输入文本
if [ ${#files[@]} -eq 0 ]; then
    # 没有指定文件，从标准输入读取
    input_text=$(cat)
    if [ -z "$input_text" ]; then
        echo "错误: 没有输入文本" >&2
        echo "使用 ./token-count.sh --help 查看帮助信息" >&2
        exit 1
    fi

    # 分析文本
    result=$(analyze_text "$input_text" "stdin")
    IFS='|' read -r total_tokens english_tokens chinese_tokens punctuation_tokens source <<< "$result"

    if [ "$output_format" = "json" ]; then
        echo "{"
        echo "  \"source\": \"$source\","
        echo "  \"total_tokens\": $total_tokens,"
        echo "  \"details\": {"
        echo "    \"english_tokens\": $english_tokens,"
        echo "    \"chinese_tokens\": $chinese_tokens,"
        echo "    \"punctuation_tokens\": $punctuation_tokens"
        echo "  }"
        echo "}"
    else
        echo "估算 token 数量: $total_tokens"
        echo "--- 详细统计 ---"
        echo "英文单词 token: $english_tokens"
        echo "中文字符 token: $chinese_tokens"
        echo "标点数字 token: $punctuation_tokens"
    fi
else
    # 处理一个或多个文件
    if [ "$output_format" = "json" ]; then
        echo "["
        first_file=true

        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                echo "错误: 文件不存在: $file" >&2
                exit 1
            fi

            if [ "$first_file" = false ]; then
                echo ","
            fi
            first_file=false

            input_text=$(cat "$file")
            result=$(analyze_text "$input_text" "$file")
            IFS='|' read -r total_tokens english_tokens chinese_tokens punctuation_tokens source <<< "$result"

            echo "  {"
            echo "    \"source\": \"$source\","
            echo "    \"total_tokens\": $total_tokens,"
            echo "    \"details\": {"
            echo "      \"english_tokens\": $english_tokens,"
            echo "      \"chinese_tokens\": $chinese_tokens,"
            echo "      \"punctuation_tokens\": $punctuation_tokens"
            echo "    }"
            echo "  }"
        done

        echo ""
        echo "]"
    else
        for file in "${files[@]}"; do
            if [ ! -f "$file" ]; then
                echo "错误: 文件不存在: $file" >&2
                exit 1
            fi

            echo "文件: $file"
            echo "---"

            input_text=$(cat "$file")
            result=$(analyze_text "$input_text" "$file")
            IFS='|' read -r total_tokens english_tokens chinese_tokens punctuation_tokens source <<< "$result"

            echo "估算 token 数量: $total_tokens"
            echo "英文单词 token: $english_tokens"
            echo "中文字符 token: $chinese_tokens"
            echo "标点数字 token: $punctuation_tokens"

            # 如果有多个文件，添加空行分隔
            if [ ${#files[@]} -gt 1 ]; then
                # 获取最后一个文件的索引
                last_index=$((${#files[@]} - 1))
                if [ "$file" != "${files[$last_index]}" ]; then
                    echo
                fi
            fi
        done
    fi
fi

