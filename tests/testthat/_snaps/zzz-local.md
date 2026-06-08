# rd_translate() produces correct output with Ollama

    Code
      rd_test_translate(test_path("rd/lang_help.Rd"))
    Message
      v lang - Translation complete
    Output
      _D_o_c_u_m_e_n_t_a_c_i_ó_n _d_e _a_y_u_d_a _p_a_r_a _t_r_a_d_u_c_i_r _a _o_t_r_o _i_d_i_o_m_a.
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Traduce un tema dado a otro idioma. Utiliza el argumento 'lang'
           para determinar qué idioma traducir. Si no se pasa este argumento,
           esta función buscará un idioma objetivo en las variables de
           entorno LANG y LANGUAGE o, si se ha pasado algún argumento al
           '.lang()' en la función 'lang_use()', para determinar el idioma
           objetivo. Si el idioma objetivo es inglés, no se procesará la
           traducción, por lo que se devolverá la documentación del paquete
           original.
      
      _U_s_a_g_e:
      
           lang_help(
             topic,
             package = NULL,
             lang = NULL,
             context_size = NULL,
             type = getOption("help_type")
           )
           
      _A_r_g_u_m_e_n_t_s:
      
         topic: Texto de ayuda para traducir.
      
       package: El paquete de R a buscar se proporciona como argumento, si no
                está disponible la función intentará encontrar el tema en las
                bibliotecas cargadas.
      
          lang: Caracter vector de idioma para traducir el tema a
      
      context_size: Número máximo de palabras para la suma de contexto
                incluido con cada solicitud de traducción. Establecido en '0'
                para desactivar la traducción contextual. Cuando es 'NULL',
                el valor establecido mediante 'lang_use()' se utiliza (por
                defecto, '100').
      
          type: Produce "html" o "text" salida para la ayuda. Se configura
                por defecto con la opción 'getOption("help_type")'.
      
      _V_a_l_u_e:
      
           Aquí está una descripción general del producto:
      
           * Traduce la documentación de ayuda a otro idioma * Utiliza el
           argumento 'lang', variables de entorno y la función '.lang()' para
           determinar el idioma objetivo * Asume un paquete (opcional), un
           tema, un idioma, un tamaño de contexto y un tipo (html/text) como
           entrada * Regresa el valor 'intro' en el tipo de salida deseado.
      
           La versión original o traducida de la documentación del producto
           en el formato especificado.
      
      _E_x_a_m_p_l_e_s:
      
           # Requiere una sesión interactiva con Ollama ejecutada localmente.
           library(lang)
           
           lang_use("ollama", "llama3.2", seed = 100)
           
           lang_help("lang_help", lang = "spanish", type = "text")
           

---

    Code
      rd_test_translate(test_path("rd/aes.rds"))
    Message
      v lang - Translation complete
    Output
      _C_o_n_s_t_r_u_i_r _m_a_p_e_o_s _e_s_t_é_t_i_c_o_s
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Las mapeos estéticos describen cómo las variables en los datos se
           mapan a las propiedades visuales (estética) de geoms. Los mapeos
           estéticos pueden ser configurados con 'ggplot()' y en capas
           individuales. Se omite comúnmente el eje x y y, mientras que todas
           las otras propiedades deben ser nombradas.
      
           La interpolación quasisinónica permite un uso fácil con variables
           de la hoja de datos nombrándolas directamente. 'vars()' es otra
           función de citado diseñada para especificaciones de capas. La
           evaluación atrasada permite trabajar con variables computadas.
           Documentación adicional sobre otras estéticas se puede encontrar
           en 'aes_colour_fill_alpha', 'aes_group_order',
           'aes_linetype_size_shape', 'aes_position'.
      
      _U_s_a_g_e:
      
           aes(x, y, ...)
           
      _A_r_g_u_m_e_n_t_s:
      
      x, y, ...: La lista de pares de nombres que describe cómo las variables
                en los datos se mapan a las propiedades visuales (estética)
                de geoms. La lista de pares de nombres puede ser configurada
                con 'ggplot()' y en capas individuales. Se omite comúnmente
                el eje x y y, mientras que todas las otras propiedades deben
                ser nombradas.
      
                La interpolación quasisinónica permite un uso fácil con
                variables de la hoja de datos nombrándolas directamente.
                'vars()' es otra función para especificaciones de capas. La
                evaluación atrasada permite trabajar con variables
                computadas.
      
                Se puede encontrar más información sobre otras estéticas en
                'aes_colour_fill_alpha', 'aes_group_order',
                'aes_linetype_size_shape', 'aes_position'.
      
      _D_e_t_a_i_l_s:
      
           Esta función también estándariza los nombres de estéticas al
           convertir 'color' a 'colour' (también en subcadenas, como
           'point_color' a 'point_colour') y traduciendo los nombres estilo R
           antiguos a los nombres de ggplot (por ejemplo, 'pch' a 'shape' y
           'cex' a 'size').
      
      _V_a_l_u_e:
      
           Un objeto S7 que representa una lista con clase 'mapping'.
           Componentes de la lista son Either constantes o expresiones.
      
      _C_i_t_a_c_i_ó_n _q_u_a_s_e:
      
           La función 'aes()' es una función de citación. Esto significa que
           sus entradas se citan para ser evaluadas en el contexto de los
           datos. Esto hace que sea fácil trabajar con variables del data
           frame porque puedes nombrarlas directamente. La contradicción es
           que debes usar citación quasiana para programar con 'aes()'.
           Consulta una tutorial de evaluación quirúrgica en la sección de
           programación de dplyr para aprender más sobre estos técnicas.
      
      _N_o_t_e:
      
           Usando 'I()' para crear objetos de clase 'AsIs' hace que las
           escalas ignoren la variable y asuma que el valor wrapado es una
           entrada directa al paquete de gráficos. Se debe tener en cuenta
           que las variables a veces se combinan, como en algunos ajustes
           estadísticos o ajustes de posición, lo que puede generar
           resultados inesperados con las variables 'AsIs'.
      
      _S_e_e _A_l_s_o:
      
           Las mapeos estéticos describen cómo las variables en los datos se
           mapan a las propiedades visuales (estética) de geoms. Los mapeos
           estéticos pueden ser configurados con 'ggplot()' y en capas
           individuales. Se omite comúnmente el eje x y y, mientras que todas
           las otras propiedades deben ser nombradas.
      
           La interpolación quasisinónica permite un uso fácil con variables
           de la hoja de datos nombrándolas directamente. 'vars()' es otra
           función diseñada para especificaciones de capas. La evaluación
           atrasada permite trabajar con variables computadas. Documentación
           adicional sobre otras estéticas se puede encontrar en
           'aes_colour_fill_alpha', 'aes_group_order',
           'aes_linetype_size_shape', 'aes_position'.
      
           Para ver un resumen de otras estéticas que pueden modificarse,
           utilice el comando 'vignette("ggplot2-specs")'.
      
           La evaluación atrasada es útil para trabajar con variables
           calculadas.
      
           Otra documentación sobre estéticas adicionales se puede encontrar
           en 'aes_colour_fill_alpha', 'aes_group_order',
           'aes_linetype_size_shape', 'aes_position'
      
      _E_x_a_m_p_l_e_s:
      
           aes(x = mpg, y = wt)
           aes(mpg, wt)
           
           # Puedes también mapear estéticas a funciones de variables.
           aes(x = mpg ^ 2, y = wt / cyl)
           
           # O para constantes
           aes(x = 1, colour = "smooth")
           
           # Los nombres de las estéticas se normalizan automáticamente.
           aes(col = x)
           aes(fg = x)
           aes(color = x)
           aes(colour = x)
           
           # Las estéticas (`aes`) se pasan a la función `ggplot()` o específica capa, y los esteticismos suministrados se utilizan para especificar las propiedades de los géomos.
           # Se utilizan como defaults para cada capa de ggplot().
           ggplot(mpg, aes(displ, hwy)) + geom_point()
           ggplot(mpg) + geom_point(aes(displ, hwy))
           
           # La evaluación atrasada permite trabajar con variables computadas.
           # Las mapeos estéticos describen cómo las variables en los datos se mapan a las propiedades visuales (estética) de geoms. Los mapeos estéticos pueden ser configurados con `ggplot()` y en capas individuales. Se omite comúnmente el eje x y y, mientras que todas las otras propiedades deben ser nombradas.
           
           La interpolación quasisinónica permite un uso fácil con variables de la hoja de datos nombrándolas directamente.
           `vars()` es otra función de citado diseñada para especificaciones de capas.
           La evaluación atrasada permite trabajar con variables computadas.
           Documentación adicional sobre otras estéticas se puede encontrar en `aes_colour_fill_alpha`, `aes_group_order`, `aes_linetype_size_shape`, `aes_position`.
           
           La interpolación quasisinónica permite un uso fácil con variables de la hoja de datos nombrándolas directamente.
           # La evaluación permite crear envolturas alrededor de los pipelines de ggplot2.
           # El caso más simple ocurre cuando tu envoltura toma puntos.
           scatter_by <- function(data, ...) {
             ggplot(data) + geom_point(aes(...))
           }
           scatter_by(mtcars, disp, drat)
           
           # Si tu envoltura tiene una interfaz más específica con argumentos nombrados.
           # "necesitas el operador de abrazo:"
           scatter_by <- function(data, x, y) {
             ggplot(data) + geom_point(aes({{ x }}, {{ y }}))
           }
           scatter_by(mtcars, disp, drat)
           
           # Señores del mapeo, es posible utilizar sus propias funciones dentro de la capa estética.
           # Las expresiones encuadradas y todas resolverán como deberían.
           cut3 <- function(x) cut_number(x, 3)
           scatter_by(mtcars, cut3(disp), drat)
           

