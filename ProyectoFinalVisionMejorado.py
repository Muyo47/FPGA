import cv2
import numpy as np
import matplotlib.pyplot as plt

# Imagenes plantilla, son siempre las mismas
# En caso de cambiar la referencia, asegurar tambien que ruta_imagen_base es la mascara manual de ruta_imagen
ruta_imagen = 'STM_pcb.png'
ruta_imagen_base = 'STM_pcb_pcbbase.png'



# Set de imagenes a analizar
# Cambiar para realizar el analisis. Solo es necesario variar la ruta de la imagen
ruta_imagen_defectuosa = 'STM_pcb_defectuosa.png'

#ruta_imagen_girada = 'STM_pcb_girada.png'
ruta_imagen_girada = 'STM_pcb_girada_defectuosa.png'
#ruta_imagen_girada = 'STM_pcb_girada_defectuosa_multiple.png'

#ruta_imagen_girada_2 = 'STM_pcb_girada_2.png'
ruta_imagen_girada_2 = 'STM_pcb_girada_2_defectuosa.png'

#ruta_imagen_muy_girada = 'STM_pcb_muy_girada_defectuosa.png'
ruta_imagen_muy_girada = 'STM_pcb_muy_girada_2.png'

def CrearPlantilla(rutaimg, rutaimg_base):
    imagen = cv2.imread(rutaimg)
    imagenRGB = cv2.imread(rutaimg, cv2.COLOR_BGR2RGB)
    imagen_base = cv2.imread(rutaimg_base)
    imagen_baseHSV = cv2.cvtColor(imagen_base, cv2.COLOR_BGR2HSV)
    h_b, s_b, v_b = cv2.split(imagen_baseHSV)
    retHSV_b,maskHSV_b =  cv2.threshold(v_b, 0, 255, cv2.THRESH_OTSU) # Segmentacion de Otsu
    maskHSV_b = 255- maskHSV_b

    resized_maskHSV_b = cv2.resize(maskHSV_b, (500, 500), interpolation=cv2.INTER_LINEAR)
    cv2.imshow("Imagen HSV", resized_maskHSV_b)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    kernelApertura_b = cv2.getStructuringElement(cv2.MORPH_RECT,(20,20)) #10 10 ORIGINALMENTE
    kernelCircular_b = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(10,10))
    imagen_apertura_b = cv2.morphologyEx(maskHSV_b, cv2.MORPH_OPEN, kernelApertura_b)
    imagen_cierre_b = cv2.morphologyEx(imagen_apertura_b, cv2.MORPH_CLOSE, kernelCircular_b)

# Espacio de color HSV
    imgHSV = cv2.cvtColor(imagen, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(imgHSV)
    fig, axs = plt.subplots(2, 2)
    axs[0,0].imshow(imgHSV)
    axs[0,0].set(title = 'Espacio de color HSV')
    axs[0,1].imshow(h)
    axs[0,1].set(title = 'Canal Matiz')
    axs[1,0].imshow(s)
    axs[1,0].set(title = 'Canal Saturación')
    axs[1,1].imshow(v)
    axs[1,1].set(title = 'Canal Valor')
    fig.tight_layout()
    plt.axis('off')
    plt.show()

    canalHSV = v 
    retHSV,maskHSV =  cv2.threshold(canalHSV, 0, 255, cv2.THRESH_OTSU) # Segmentación de Otsu
    maskHSV = 255- maskHSV

    resized_maskHSV = cv2.resize(maskHSV, (500, 500), interpolation=cv2.INTER_LINEAR)  # Para ver mejor la imagen
    cv2.imshow("Imagen HSV", resized_maskHSV)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    kernelApertura = cv2.getStructuringElement(cv2.MORPH_RECT,(28,28)) #10 10 ORIGINALMENTE
    kernelCircular = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(10,10))
    imagen_apertura = cv2.morphologyEx(maskHSV, cv2.MORPH_OPEN, kernelApertura)
    imagen_cierre = cv2.morphologyEx(imagen_apertura, cv2.MORPH_CLOSE, kernelCircular)

    resized_apertura = cv2.resize(imagen_apertura, (500, 500), interpolation=cv2.INTER_LINEAR)
    cv2.imshow("Mascara de apertura", resized_apertura)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    resized_cierre = cv2.resize(imagen_cierre, (500, 500), interpolation=cv2.INTER_LINEAR)
    cv2.imshow("Mascara de cierre", resized_cierre)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    imagen_cierre_b = 255 - imagen_cierre_b
    maskComb = cv2.bitwise_and(imagen_cierre, imagen_cierre_b)
    resized_maskComb = cv2.resize(maskComb, (500, 500), interpolation=cv2.INTER_LINEAR)
    cv2.imshow("Mascara final correlacionada", resized_maskComb)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    num_label, labels, stats, centroides = cv2.connectedComponentsWithStats(maskComb)

    imagen_resultado = imagenRGB.copy()
    for label in range(1, num_label):  # Ignorar el fondo (label 0)
        x, y, w, h, area = stats[label]
        cv2.rectangle(imagen_resultado, (x, y), (x + w, y + h), (0, 0, 255), 2)
        cv2.putText(imagen_resultado, f'COMPONENTE: {label}', (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2)

# Imagen final con los componentes a analizar recuadrados
    plt.figure(figsize=(10, 10))
    plt.imshow(cv2.cvtColor(imagen_resultado, cv2.COLOR_BGR2RGB))
    plt.title('Componentes plantilla detectados')
    plt.axis('off')
    plt.show()
    
    return (stats, num_label, labels, centroides)


def rectificar_imagen(ruta_imagen_referencia, ruta_imagen_rotada):

    img_ref = cv2.imread(ruta_imagen_referencia, cv2.IMREAD_COLOR)
    img_rot = cv2.imread(ruta_imagen_rotada, cv2.IMREAD_COLOR)

    gray_ref = cv2.cvtColor(img_ref, cv2.COLOR_BGR2GRAY)
    gray_rot = cv2.cvtColor(img_rot, cv2.COLOR_BGR2GRAY)


    orb = cv2.ORB_create()
    keypoints_ref, descriptors_ref = orb.detectAndCompute(gray_ref, None)
    keypoints_rot, descriptors_rot = orb.detectAndCompute(gray_rot, None)


    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
    matches = bf.match(descriptors_ref, descriptors_rot)
    matches = sorted(matches, key=lambda x: x.distance)

    img_matches = cv2.drawMatches(img_ref, keypoints_ref, img_rot, keypoints_rot, matches[:50], None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
    plt.figure(figsize=(12, 8))
    plt.imshow(cv2.cvtColor(img_matches, cv2.COLOR_BGR2RGB))
    plt.title('Emparejamientos entre la imagen de referencia y la girada')
    plt.axis('off')
    plt.show()


    if len(matches) > 10:  # Asegurarse de tener suficientes puntos
        src_pts = np.float32([keypoints_ref[m.queryIdx].pt for m in matches]).reshape(-1, 1, 2)
        dst_pts = np.float32([keypoints_rot[m.trainIdx].pt for m in matches]).reshape(-1, 1, 2)
        H, mask = cv2.findHomography(dst_pts, src_pts, cv2.RANSAC, 5.0)     # RANSAC dado que tenemos muchos mas emparejamientos que los 4 minimos

        # Aplicamos la matriz de transformacion (homografia)
        h, w, _ = img_ref.shape
        img_alineada = cv2.warpPerspective(img_rot, H, (w, h))

        plt.figure(figsize=(10, 10))
        plt.imshow(cv2.cvtColor(img_alineada, cv2.COLOR_BGR2RGB))
        plt.title('Imagen girada alineada con la de referencia')
        plt.axis('off')
        plt.show()
    else:
        print("No se encontraron suficientes puntos para calcular la homografía.")

    return (img_alineada)
    
    
# Funcion para crear el histograma de correlacion
def CrearHistogramaCorrelacion(stats, correlaciones):
    componentes = range(1, len(stats))  # Ignorar el fondo (label 0)
    plt.figure(figsize=(10, 6))
    plt.bar(componentes, correlaciones, color='blue')
    plt.xlabel('Componentes')
    plt.ylabel('Correlación')
    plt.title('Histograma de Correlación de Componentes')
    plt.show()
    
    
def AnalizarComponentesConCorrelacion(img_patron, img_rectificada, stats, umbral_correlacion=0.1):
    img_resultado = img_rectificada.copy()
    correlaciones = []

    for i, stat in enumerate(stats[1:], start=1):  # Ignorar el fondo (label 0)
        x, y, w, h, area = stat
        roi_patron = img_patron[y:y+h, x:x+w]  # ROI de la imagen plantilla
        roi_rectificada = img_rectificada[y:y+h, x:x+w]  # ROI correspondiente de la imagen rectificada

        res = cv2.matchTemplate(roi_rectificada, roi_patron, cv2.TM_CCOEFF_NORMED)
        max_corr = res.max()  # Maxima correlacion obtenida
        correlaciones.append(max_corr)

        color_rectangulo = (0, 255, 0) if max_corr >= umbral_correlacion else (0, 0, 255)
        cv2.rectangle(img_resultado, (x, y), (x + w, y + h), color_rectangulo, 2)
        cv2.putText(img_resultado, f'COMPONENTE: {i}', (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color_rectangulo, 2)

    plt.figure(figsize=(10, 10))
    plt.imshow(cv2.cvtColor(img_resultado, cv2.COLOR_BGR2RGB))
    plt.title('Componentes analizados')
    plt.axis('off')
    plt.show()

    CrearHistogramaCorrelacion(stats, correlaciones)


# Llamada a las funciones


imagen_template = cv2.imread(ruta_imagen)

# Obtener posiciones de los componentes del template
# Esto es siempre asi, genera una plantilla de los componentes fundamentales
# EN CASO DE CAMBIAR LA IMAGEN PLANTILLA DE REFERENCIA, LA ruta_imagen CONTIENE LA PLACA DE DESARROLLO COMPLETA,
# MIENTRAS QUE ruta_imagen_base ES LA MASCARA MANUAL DE LOS COMPONENTES A IDENTIFICAR. DEBEN SER FOTOS SIMILARES,
# LA UNICA DIFERENCIA ENTRE AMBAS ES QUE LA IMAGEN BASE NO CONTIENE LOS COMPONENTES A DETECTAR!!!
(stats, num_etiquetas, etiquetas, centroides) = CrearPlantilla(ruta_imagen, ruta_imagen_base)

# Rectifica la imagen girada, tambien puede rectificar una imagen basica
# Para el analisis SOLO hay que variar el segundo parametro de esta funcion
# Se puede incluir cualquier imagen en cualquier rotacion, con o sin componentes sobrantes o faltantes
# No es capaz de detectar componentes de mas
imagen_rectificada = rectificar_imagen(ruta_imagen, ruta_imagen_girada)

# Analiza los componentes en la imagen rectificada, usa la imagen plantilla, que es la imagen basica (no cambiar imagen_template)
# Usa tambien la imagen ya rectificada, y las roi de la imagen plantilla
# NO SE DEBE CAMBIAR NINGUN PARAMETRO DE ENTRADA DE ESTA FUNCION, ESTA TOTALMENTE AUTOMATIZADA
AnalizarComponentesConCorrelacion(imagen_template, imagen_rectificada, stats)
