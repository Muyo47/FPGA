from pynq import Overlay, MMIO  # Librerias de pynq
import threading  # Libreria para implementar hilos
import queue  # Colas
import time  # A dormir 😴

# -----------------------------------------------------------------------------
# Variables, flags
# -----------------------------------------------------------------------------

LED_flag = 0x0
sysmanager_flag = 0x0
flag_reg = 0x0
bgBit = 12

# -----------------------------------------------------------------------------
# Inicio de la UART LITE direccion base, MMIO
# -----------------------------------------------------------------------------
#BITSTREAM = "/home/xilinx/jupyter_notebooks/TFG_PRUEBAS/uart.bit"  # PL ANTIGUO, DARA ERROR AL EJECUTAR
BITSTREAM = "/home/xilinx/jupyter_notebooks/TFG_PRUEBAS/bitTFG.bit"  # PL DEFINITIVO
# TESTEADO, FUNCIONA BIEN CON AMBOS BITSTREAMS
UARTLITE_BASE = 0x42C00000
UARTLITE_SIZE = 0x10000   # Consultar en vivado direccion base y tamaño
SleepCte = 0.001   # Polling no bloqueante de 1 ms (el kernel puede morir si no se duerme el micro)

# Inicio de arquitectura en el PL
overlay = Overlay(BITSTREAM)
overlay.download()
uart = MMIO(UARTLITE_BASE, UARTLITE_SIZE)   # Inicio del bloque UART LITE

BASE_ADDRESS = 0x43C00000  # Direccion base del registro s00 AXI
slave0 = MMIO(BASE_ADDRESS, 0x10000)   # Rango de 64kB (0x1000 para 4kB)
slave0.write(0, 0x00000000)


# -----------------------------------------------------------------------------
# FUNCIONES UART ESCRITURA Y LECTURA
# -----------------------------------------------------------------------------
def wuart(data: int):
    # funcion de escritura UART, escribe en el FIFO Tx de la UART
    uart.write(0x4, data & 0xFF)
        
def write_uart(msg: str, chunk_size: int = 16):    # Este tamaño de chunk es suficiente para evitar cuelgues
    # Trocea el mensaje. Necesario para evitar la muerte del kernel
    for i in range(0, len(msg), chunk_size):
        chunk = msg[i:i+chunk_size]
        for c in chunk:
            while uart.read(0x8) & 0x2:
                time.sleep(0.01)
            wuart(ord(c))
        time.sleep(0.01)  # Espera entre bloques

def read_uart() -> int | None:
    status = uart.read(0x8)   # Lee el registro STATUS
    if status & 0x1:     # Bit 0 = RX data ready
        return uart.read(0x0) & 0xFF   # Lectura del registro Rx
    return None   # Si no hay datos disponibles

# -----------------------------------------------------------------------------
# COLA DE MENSAJES, EVENTO DE PARADA
# -----------------------------------------------------------------------------
msg_queue = queue.Queue()
_stop_event = threading.Event()

def uart_polling_thread():
    
    buffer_line = ""    # Buffer de mensaje recibido por UART
    while not _stop_event.is_set():
        dato = read_uart()
        if dato is not None:    # El daro capturado es correcto, se escribe en el string
            c = chr(dato)
            if c == '\n':    # Importante, la transmision debe incluir SALTO DE LINEA al final de la transmision (LF)
                msg_queue.put(buffer_line)    # El buffer se pone en cola
                buffer_line = ""    # Se vacia el buffer para transmision futura
            else:
                buffer_line += c    # Si no se ha alcanzado el final, se siguen añadiendo los caracteres recibidos al buffer
        else:
            time.sleep(SleepCte)    # Evita la muerte del kernel en caso de transmision extremadamente rapida

# -----------------------------------------------------------------------------
# DEFINICIONES DE CMD Y CALLBACKS
# -----------------------------------------------------------------------------
def cmd_set_led(args: list[str]):    # Callback de SETLED
    # Usamos la variable global
    global LED_flag
    
    if len(args) != 1:    # Solo se acepta un argumento, ni 0 ni mas de uno (separado por comas sin espacio)
        write_uart("SETLED: Necesita argumentos. EINFO para mas informacion\n")
        return
    try:
        nivel = int(args[0])    # SOLO CAPTURA EL PRIMER ARGUMENTO, SI SE SEPARAN CON COMAS FALLA (debug)
    except ValueError:    # Si el argumento capturado no es exclusivamente numerico
        write_uart("SETLED: El argumento no es valido\n")
        return
    if not 0 <= nivel <= 3:    # Si el argumento capturado esta fuera de rango
        write_uart("SETLED: nivel fuera de rango\n")
        return
    # Aqui va la logica real, p.ej. activar GPIO o enviar por UART:
    
    # Verificar y cambiar el estado del LED seleccionado
    if (LED_flag >> nivel) & 0x1:  # Si esta encendido, apaga el LED y limpia flag
        LED_flag &= ~(1 << nivel)
        write_uart(f"LED {nivel} apagado\n")
        print("debug")
    else:
        LED_flag |= (1 << nivel)  # Enciende el LED, activa flag
        write_uart(f"LED {nivel} encedido\n")
    
    # Depuracion
    write_uart(f"Estado actual: 0b{LED_flag:04b} (0x{LED_flag:X})\n")
    

def cmd_set_background(args: list[str]):
    global bgbit
    if len(args) != 1:
        write_uart("SETBG: Necesita argumentos\n")
        return
    
    try:
        fondo = int(args[0])
    except ValueError:    # Si el argumento capturado no es exclusivamente numerico
        write_uart("SETBG: El argumento no es valido\n")
        return
    
    if fondo not in (0, 1):
        write_uart("SETBG: El fondo seleccionado no es valido\n")
        return
    else:
        write_uart(f"Seleccionado fondo {fondo}\n")
        prev_bg = slave0.read(0)
        prev_bg &= ~(1 << bgBit)    # Limpia el bit de la posicion 12 (background PL)
        prev_bg |= (fondo & 0x1) << 12    # & 0x1 restringe al lsb de fondo (variable)
        slave0.write(0, prev_bg)
        return

    
def cmd_status(args: list[str]):    # Callback de STATUS
    global sysmanager_flag
    if len(args) == 0:    # Exclusivo argumento void
        write_uart(f"El estado actual del sistema es:\nLEDS: {LED_flag:04b}\n")
        if sysmanager_flag == 0x1:
            write_uart("Modo administrador activo\n")
        return
    else:
        write_uart("STATUS: No se aceptan argumentos\n")
        return
    
    
def cmd_info(args: list[str]):
    if len(args) == 0:    # Exclusivo argumento void
        write_uart("Los TAGS existentes hasta el momento son:\nSETLED\nSTATUS\nINFO\nEINFO\nEl parser es :: y la estructura de comandos del estilo TAG::ARG\nUsa EINFO::[TAG] para obtener informacion especifica del TAG\n")
        return
    else:
        write_uart("INFO: No se aceptan argumentos\n")
        return
    
    
def cmd_einfo(args: list[str]):
    if len(args) != 1:  # Solo acepta un argumento
        write_uart("EINFO: Necesita argumentos. EINFO para mas informacion\n")
        return

    arg = args[0].strip()  # Elimina espacios en blanco alrededor

    # Lista de comandos validos
    comandos_validos = {"STATUS", "SETLED", "INFO", "EINFO", "SYSMANAGER"}

    if not arg.isalpha():  # Verifica que el argumento sea solo letras
        write_uart("EINFO: Argumento no valido\n")
        return

    if arg not in comandos_validos:
        write_uart(f"ERROR: Argumento '{arg}' no reconocido. Argumentos aceptados: {', '.join(comandos_validos)}\n")
        return

    if arg == "STATUS":
        write_uart("STATUS:: proporciona el estado del sistema. No acepta argumentos\n")
    elif arg == "SETLED":
        write_uart("SETLED::[int] activa un LED\nEl argumento debe ser un uint, con rango [0,3]\n")
    elif arg == "INFO":
        write_uart("INFO:: proporciona informacion basica. No acepta argumentos")
    elif arg == "EINFO":
        write_uart(f"EINFO::[TAG]\nproporciona informacion detallada del comando.\nArgumentos aceptados: {', '.join(comandos_validos)}\n")
    elif arg == "SYSMANAGER":
        write_uart("SYSMANAGER:: permite acceso al modo desarrollador del sistema. Utiliza el comando con argumento vacio inicialmente\nUna vez en modo administrador, los argumentos disponibles son\n[REGEDIT] permite edicion directa del registo 0 AXI\n[REGSTATUS] devuelve el valor del registro 0 AXI\nVuelve a llamar a SYSMANAGER:: para salir del modo administrador\n")
        
        
        
def cmd_sysmanager(args:list[str]):
    global sysmanager_flag
    global flag_reg
    if len(args) == 0:    # Exclusivo argumento void
        if sysmanager_flag == 0x1:
            write_uart("Se ha cerrado el modo administrador\n")
            sysmanager_flag = 0x0
            return
        
        write_uart("Introduce la contraseña de administrador:\n")
        password = ""
        while True:
            char_code = read_uart()
            if char_code is not None:
                char = chr(char_code)
                if char == '\n':
                    break
                password += char

        if password == "1234":
            sysmanager_flag = 0x1
            write_uart("Modo administrador activado\n")
        else:
            write_uart("Contraseña incorrecta. Acceso denegado.\n")
    elif len(args) == 1:
        if sysmanager_flag != 0x1:
            write_uart("SYSMANAGER: Acceso denegado. No estas en modo administrador.\n")
            return

        if args[0] == "REGEDIT":
            write_uart("Advertencia!\nEditar directamente los registros puede bloquear el programa\n")
            write_uart("Escribe los 32 bits del registro AXI0 sin separar y en formato binario\n")

            regAXI0 = ""
            flag_reg = 0x0  # Inicializar antes del bucle

            while True:
                char_reg = read_uart()
                if char_reg is not None:
                    char = chr(char_reg)
                    if char == '\n':
                        if len(regAXI0) != 32:
                            write_uart("Error: El registro es menor o mayor de 32 bits\n")
                        else:
                            flag_reg = 0x1
                            break

                    if char not in ('0', '1'):
                        write_uart(f"Caracter no valido: {char}\nSolo se aceptan 0 o 1\n")
                        # Si se escriben menos de 32 caracteres, hay un bug que cuenta \n como caracter,
                        # y salta el mensaje de caracter invalido
                        break

                    regAXI0 += char

            if flag_reg == 0x1:
                # Aquí haces el MMIO real
                valor = int(regAXI0, 2)    # int (variable, x) la x es la base (base 2 -> bin)
                flag_reg = 0x0
                slave0.write(0, valor)
                write_uart(f"AXI0 actualizado con valor: {valor:032b}\n")
                    
        elif args[0] == "REGSTATUS":
            reg0 = slave0.read(0)
            write_uart(f"El registro 0 tiene el siguiente valor:\nBinario: {reg0:032b}\nHex: 0x{reg0:08X}\n")
        else:
            write_uart("SYSMANAGER: Argumento desconocido\n")
    else:
        write_uart("SYSMANAGER: Argumento invalido\n")
        return
        
    
# Diccionario de TAGS con su callback
COMMANDS: dict[str, callable] = {
    "SETLED": cmd_set_led,
    "STATUS": cmd_status,
    "INFO": cmd_info,
    "EINFO": cmd_einfo,
    "SETBG": cmd_set_background,
    "SYSMANAGER": cmd_sysmanager
}

def parse(msg: str):    # PARSER, fundamental para estructurar los comandos
   # Comprueba que el mensaje tenga el formato CMD exacto TAG::ARG separado de :: para evitar falsos mensajes
    if "::" not in msg:    # Esto es a eleccion del desarrollador, para este caso el parser es ::
        write_uart("El formato no es correcto. Usa TAG::ARG\n")
        return
    tag, rest = msg.split("::", 1)    # Parser
    args = rest.split(",") if rest else []    # Los argumentos multiples van separados por comas
    # print(f"→ Recibido TAG='{tag}', ARG={args}")
    handler = COMMANDS.get(tag)    # Llamada a callbacks a partir del diccionario de callbacks
    if handler:
        handler(args)    # El handler llama a la callback del TAG y pasa el argumento
    else:
        write_uart("Comando invalido\n")    # Si el TAG no esta en el diccionario

# -----------------------------------------------------------------------------
# ARRANQUE HILO POLLING, BUCLE PRINCIPAL
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    # Inicia hilo de recepcion UART
    thread = threading.Thread(target=uart_polling_thread, daemon=True)
    thread.start()
    print("DEBUG__ iniciando el terminal")

    try:
        while True:
            try:
                # Espera hasta 100 ms por un mensaje; no bloquea el resto de tareas
                msg = msg_queue.get(timeout=0.1)
                parse(msg)
            except queue.Empty:
                # Aquí puedes ejecutar otras tareas periódicas
                pass
    except KeyboardInterrupt:
        print("DEBUG__ deteniendo terminal")
        _stop_event.set()
        thread.join()
        print("DEBUG__ OK")
