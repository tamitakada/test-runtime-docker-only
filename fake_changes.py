import re
import sys
import random


path = sys.argv[1]
garbage_lc = (int(sys.argv[2]) - 3) // 2

garbage_code = '\nint x = 5;\nString y = "hello world";\nSystem.out.println(y + " " + x);\n'

for i in range(max(0, garbage_lc)):
    garbage_code += 'x = ' + str(random.randint(1, 1000)) + ';\nSystem.out.println(x);\n'

with open(path) as f:
    code = f.read()
    print(len(re.findall(r'public static [^ ]* [^ ]*\(.*\) {', code)))
    mod = re.sub(
        r'(public static [^ ]* [^ ]*\(.*\) {)',
        fr'\1{garbage_code}',
        code
    )
    print(mod)
