import slint
import os

def get_resource_path(relative_path):
    """ Ensures the path works both in the terminal and in the compiled Nuitka binary """
    base_path = os.path.abspath(os.path.dirname(__file__))
    return os.path.join(base_path, relative_path)

def main():
    # Locate the .slint file inside the ui/ folder.
    ui_path = get_resource_path(os.path.join("ui", "main.slint"))
    ui = slint.load_file(ui_path)
    app = ui.MainWindow()

    def increment():
        app.counter += 1
        print(f"Value: {app.counter}")

    app.process_click = increment
    app.run()

if __name__ == "__main__":
    main()
