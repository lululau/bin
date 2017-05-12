#!/bin/bash

perl -ne '$a.=$_; END{$a=~s/^#.*/$&\n-----/mg;$a=~s/\n\n\`\`\`/\n>\n\`\`\`/g;print $a}'