import re
import sys

def fix_result_failure(content):
    # Pattern to match Result.failure( with 2 arguments across multiple lines
    # Matches: Result.failure(\n        Exception(...),\n        '...',\n      );
    pattern = r'Result\.failure\(\s*([^,]+),\s*[^)]+\s*\)'

    def replacer(match):
        exception_part = match.group(1).strip()
        return f'Result.failure(\n        {exception_part},\n      )'

    return re.sub(pattern, replacer, content, flags=re.DOTALL)

if __name__ == '__main__':
    file_path = sys.argv[1]

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    fixed_content = fix_result_failure(content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f'Fixed {file_path}')
