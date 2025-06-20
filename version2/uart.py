import tkinter as tk
import serial
import threading
import time

# === UART CONFIG ===
ser = serial.Serial('COM3', 9600, timeout=1)

# === GLOBAL STATE ===
gui_val = 0
running = True

# === SENDER THREAD ===
def send_uart():
    while running:
        # GUI [-62 to +63] → UART [130 to 255]
        mapped_val = max(130, min(255, gui_val + 192))
        ser.write(bytes([mapped_val]))
        time.sleep(0.05)

# === CALLBACK FOR SLIDER ===
def on_slider_change(val):
    global gui_val
    try:
        gui_val = int(float(val))
        mapped = max(130, min(255, gui_val + 192))
        label_val.config(text=f"GUI: {gui_val} → UART: {mapped}")
    except ValueError:
        label_val.config(text="Invalid")

# === CLEANUP ON CLOSE ===
def on_close():
    global running
    running = False
    time.sleep(0.1)
    ser.close()
    root.destroy()

# === GUI SETUP ===
root = tk.Tk()
root.title("UART Servo Control: GUI -62 to +63 → UART 130 to 255")

slider = tk.Scale(root, from_=-62, to=63, orient=tk.HORIZONTAL,
                  length=400, resolution=1, command=on_slider_change)
slider.set(0)
slider.pack(pady=10)

label_val = tk.Label(root, text="GUI: 0 → UART: 192")
label_val.pack(pady=5)

threading.Thread(target=send_uart, daemon=True).start()
root.protocol("WM_DELETE_WINDOW", on_close)
root.mainloop()
