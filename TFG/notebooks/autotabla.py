import tkinter as tk

FILA = 30
COLUMNA = 32
CELDA_SIZE = 25

COLORES = ["#ffffff", "#12fde1", "#f0fb7c", "#a9f900", "#00f7b2", "#770092", "#617333", "#8861af",
          "#45ef45", "#ffed00", "#aaeb99", "#ff00ff", "#ff554a", "#9ce508", "#70e380", "#d5e0d5"]

class GridEditor:
    def __init__(self, root):
        self.root = root
        self.canvas = tk.Canvas(root, width=COLUMNA*CELDA_SIZE, height=FILA*CELDA_SIZE, bg='white')
        self.canvas.pack()
        self.grid = [[0 for _ in range(COLUMNA)] for _ in range(FILA)]
        self.canvas.bind("<Button-1>", self.on_click)
        self.draw_grid()

        export_button = tk.Button(root, text="Exportar a VHDL", command=self.export)
        export_button.pack()

    def draw_grid(self):
        self.canvas.delete("all")
        for i in range(FILA):
            for j in range(COLUMNA):
                x1 = j * CELDA_SIZE
                y1 = i * CELDA_SIZE
                x2 = x1 + CELDA_SIZE
                y2 = y1 + CELDA_SIZE
                color = COLORES[self.grid[i][j]]
                self.canvas.create_rectangle(x1, y1, x2, y2, fill=color, outline="gray")
                value = self.grid[i][j]
                self.canvas.create_text((x1 + x2) / 2, (y1 + y2) / 2, text=str(value), font=("Arial", 10))

    def on_click(self, event):
        col = event.x // CELDA_SIZE
        row = event.y // CELDA_SIZE
        if 0 <= row < FILA and 0 <= col < COLUMNA:
            self.show_value_selector(row, col, event.x_root, event.y_root)

    def show_value_selector(self, row, col, x, y):
        popup = tk.Toplevel(self.root)
        popup.wm_overrideredirect(True)
        popup.geometry(f"+{x}+{y}")

        def set_value(val):
            self.grid[row][col] = val
            self.draw_grid()
            popup.destroy()

        for i in range(16):
            b = tk.Button(popup, text=str(i), width=3, command=lambda v=i: set_value(v))
            b.grid(row=i // 4, column=i % 4)

    def export(self):
        output = []
        for row in self.grid:
            line = ", ".join(f'"{format(val, "04b")}"' for val in row)
            output.append("    " + line + ",")
        output[-1] = output[-1].rstrip(",")
        vhdl_text = "\n".join(output)
        print("\n--- VHDL OUTPUT TABLA DE NOMBRES 916 POSICIONES ---\n")
        print(vhdl_text)
        print("\n-------------------\n")

if __name__ == "__main__":
    root = tk.Tk()
    root.title("Editor de tabla VHDL 30x32")
    app = GridEditor(root)
    root.mainloop()
