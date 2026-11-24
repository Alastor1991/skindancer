"""Точка входа собранного oboi-helper: oboi-helper index|fetch|semantic <аргументы помощника>.

Собирается tools/build-helper.sh в один исполняемый файл со всеми библиотеками.
Импорты написаны явно, чтобы сборщик видел все три помощника.
"""
import sys


def main():
    names = ("index", "fetch", "semantic")
    if len(sys.argv) == 2 and sys.argv[1] == "where":
        # каталог, куда распакован этот бинарник: обёртки записывают его в метку готовности
        import os
        print(os.path.dirname(os.path.abspath(sys.executable)))
        return
    if len(sys.argv) < 2 or sys.argv[1] not in names:
        sys.exit("oboi-helper index|fetch|semantic|where …")
    name = sys.argv.pop(1)
    sys.argv[0] = "oboi-" + name
    if name == "index":
        from oboi_index import main as run
    elif name == "fetch":
        from oboi_fetch import main as run
    else:
        from oboi_semantic import main as run
    run()


if __name__ == "__main__":
    main()
