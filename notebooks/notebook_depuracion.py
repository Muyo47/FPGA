#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Overlay personalizado. Version de pruebas

from pynq import Overlay
from pynq import MMIO
over = Overlay("/home/xilinx/jupyter_notebooks/TFG_PRUEBAS/bitTEST.bit")
over.download()

# Para acceder a base adress y el rango, window -> adress editor

BASE_ADDRESS = 0x43C00000  # Direccion base del registro s00 AXI
slave0 = MMIO(BASE_ADDRESS, 0x10000)   # Rango de 64kB (0x1000 para 4kB)

# De momento, la estructura del registro queda asi:
# Bit 0 -> HandshakeBit (write enable BRAM bit)
# Bits 1 a 8 -> direccion BRAM
# Bits 9 a 16 -> datos a escribir
# Bit 31 (solo debug)
# Bit 32 (solo debug)

# slave0.write(0, 0x1)  # Hex
slave0.write(0, 0b00000000000000000000000000000001)  # Binario

val = slave0.read(0)  # Lee el registro AXI
print(f"Valor leido: {val:#010x}")

#!pwd


# In[2]:


#slave0.write(0, 0x0)
slave0.write(0, 0b00000000000000000000000000000011)

val = slave0.read(0)  # Leer el contenido del registro
print(f"Valor leido: {val:#010x}")


# In[3]:


#slave0.write(0, 0x1)
slave0.write(0, 0b00000000000000000000000000000010)

val = slave0.read(0)  # Leer el contenido del registro
print(f"Valor leido: {val:#010x}")


# In[ ]:




