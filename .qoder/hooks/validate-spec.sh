#!/bin/bash
# 钩子：编辑/写入后验证 Spec 文件
# 触发时机：PostToolUse (Write | Edit)
# 仅在修改 specs/ 目录下的文件时执行 lean-spec validate

input=$(cat)

# 从工具输入中提取文件路径
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# 仅当修改的文件在 specs/ 目录下时才验证
if echo "$file_path" | grep -q 'specs/'; then
  # 执行 lean-spec validate，捕获输出
  validation_output=$(lean-spec validate 2>&1)
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo "Spec validation warning: $validation_output" >&2
  fi
fi

# 始终允许操作继续 (exit 0)
exit 0
