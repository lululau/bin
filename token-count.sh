#!/bin/bash

# Token 计算脚本 - 支持中英文混合文本的离线估算
# 使用方法: echo "你的文本" | ./token-count.sh

# 函数：计算英文单词的 token 数量
calculate_english_tokens() {
    local text="$1"
    local word_count=$(echo "$text" | grep -oE '\b[a-zA-Z]+\b' | wc -l | tr -d ' ')

    # 英文单词平均每个单词约 0.75-1 个 token
    # 这里使用保守估计：0.85 tokens per word

    if [ "$word_count" = "0" ]; then
        echo "0"
    else
        echo "scale=2; $word_count * 0.85" | bc -l
    fi
}

# 函数：计算中文字符的 token 数量
calculate_chinese_tokens() {
    local text="$1"
    # 使用 Perl 来正确处理 Unicode 中文字符
    local char_count=$(echo "$text" | perl -C -ne 'my $count = () = /\p{Han}/g; print "$count\n"')

    # 中文字符平均每个字符约 1.5 个 token
    if [ "$char_count" = "0" ]; then
        echo "0"
    else
        echo "scale=2; $char_count * 1.5" | bc -l
    fi
}

# 函数：计算标点符号和数字的 token 数量
calculate_punctuation_numbers_tokens() {
    local text="$1"
    # 使用 Perl 来处理 Unicode 字符
    local count=$(echo "$text" | perl -C -ne 'my $count = () = /[^\p{Latin}\p{Han}\s]/g; print "$count\n"')

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

# 从标准输入读取文本
input_text=$(cat)

if [ -z "$input_text" ]; then
    echo "使用方法: echo \"你的文本\" | ./token-count.sh"
    echo "或者: cat 文件名.txt | ./token-count.sh"
    exit 1
fi

# 计算并显示 token 数量
total_tokens=$(calculate_total_tokens "$input_text")
if [ ${#input_text} -gt 100 ]; then
    preview_text="${input_text:0:100}..."
else
    preview_text="$input_text"
fi
echo "文本: $preview_text"
echo "估算 token 数量: $total_tokens"

# 显示详细统计
echo "--- 详细统计 ---"
echo "英文单词 token: $(calculate_english_tokens "$input_text")"
echo "中文字符 token: $(calculate_chinese_tokens "$input_text")"
echo "标点数字 token: $(calculate_punctuation_numbers_tokens "$input_text")"

