# lang_help() translates correctly with Ollama

    Code
      rd_test_translate(test_path("rd/lang_help.Rd"))
    Message
      v lang - Translation complete
    Output
      _D_o_c_u_m_e_n_t_a_c_i_ó_n _d_e _a_y_u_d_a _p_a_r_a _o_t_r_o _i_d_i_o_m_a
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Aquí hay una descripción resumida de la herramienta:
      
           La herramienta traduce la documentación del ayuda a otro idioma.
           Utiliza el parámetro de lenguaje, las variables de entorno y la
           función .lang() para determinar el idioma objetivo. Elige el
           paquete (por defecto), el tema, el idioma, la tamaño de contexto y
           el tipo como parámetros de entrada. La herramienta produce salida
           en formato HTML o texto dependiendo del tipo seleccionado.
      
           Elige el idioma objetivo.
      
      _U_s_a_g_e:
      
           lang_help(
             topic,
             package = NULL,
             lang = NULL,
             context_size = NULL,
             type = getOption("help_type")
           )
           
      _A_r_g_u_m_e_n_t_s:
      
         topic: El texto de ayuda que especifica el tema de ayuda para
                traducir.
      
       package: La herramienta traduce la documentación de ayuda a otro
                idioma. Utiliza el parámetro de lenguaje, las variables de
                entorno y la función .lang() para determinar el idioma
                objetivo. Elige el paquete (por defecto), el tema, el idioma,
                el tamaño de contexto y el tipo como parámetros de entrada.
                La herramienta produce salida en formato HTML o texto
                dependiendo del tipo seleccionado.
      
          lang: Un carácter vector de idioma para traducir el tema a.
      
      context_size: El número máximo de palabras para la resumen del contexto
                incluido con cada solicitud de traducción. Establecido en '0'
                para deshabilitar la traducción contextual. Cuando es 'NULL',
                el valor establecido mediante 'lang_use()' se utiliza (por
                defecto '100').
      
          type: Produce salida en formato HTML o texto dependiendo del tipo
                seleccionado.
      
      _V_a_l_u_e:
      
           Aquí hay una descripción resumida de la herramienta:
      
           La herramienta traduce la documentación del ayuda a otro idioma.
           Utiliza el parámetro de lenguaje, las variables de entorno y la
           función .lang() para determinar el idioma objetivo. Elige el
           paquete (por defecto), el tema, el idioma, la tamaño de contexto y
           el tipo como parámetros de entrada. La herramienta produce salida
           en formato HTML o texto dependiendo del tipo seleccionado.
      
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
      _C_o_n_s_t_r_u_i_r _m_a_p_p_i_n_g_s _e_s_t_é_t_i_c_o_s
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Las mapeamientos estéticos describen cómo las variables en los
           datos se mapifican a las propiedades visuales (estéticas) de
           geoms. Los mapeamientos estéticos pueden configurarse en
           'ggplot()' y en capas individuales.
      
           La lista de pares name-value se utiliza en la forma 'aesthetic =
           variable' y no requiere referencia al conjunto original de datos.
           Los nombres para las esteticas x e y son omitidos, pero todas las
           otras esteticas deben tener nombres. Esta función también
           estándariza los nombres de estética y traduce los antiguos nombres
           de R a los nombres de ggplot.
      
      _U_s_a_g_e:
      
           aes(x, y, ...)
           
      _A_r_g_u_m_e_n_t_s:
      
      x, y, ...: Las mapeamientos estéticos describen cómo las variables en
                los datos se mapifican a las propiedades visuales (estéticas)
                de geoms. Los mapeamientos estéticos pueden configurarse en
                'ggplot()' y en capas individuales.
      
                La lista de pares name-value se utiliza en la forma
                'aesthetic = variable' y no requiere referencia al conjunto
                original de datos. Los nombres para las esteticas x e y son
                omitidos, pero todas las otras esteticas deben tener nombres.
                Esta función también estándariza los nombres de estética y
                traduce los antiguos nombres de R a los nombres de ggplot.
      
      _D_e_t_a_i_l_s:
      
           Las mapeamientos estéticos describen cómo las variables en los
           datos se mapifican a las propiedades visuales (estéticas) de
           geoms. Los mapeamientos estéticos pueden configurarse en
           'ggplot()' y en capas individuales.
      
           La lista de pares name-value se utiliza en la forma 'aesthetic =
           variable' y no requiere referencia al conjunto original de datos.
           Los nombres para las esteticas x e y son omitidos, pero todas las
           otras esteticas deben tener nombres. Esta función también
           estándariza los nombres de estética y traduce los antiguos nombres
           de R a los nombres de ggplot.
      
           Esta función también estándariza los nombres de estética al
           convertir 'color' a 'colour' (también en substrings, e.g.,
           'point_color' a 'point_colour') y traduciendo los nombres del
           estilo antiguo R a los nombres de ggplot (e.g., 'pch' a 'shape' y
           'cex' a 'size').
      
      _V_a_l_u_e:
      
           Los mapeamientos estéticos describen cómo las variables en los
           datos se mapifican a las propiedades visuales (estéticas) de
           geoms. Los mapeamientos estéticos pueden configurarse en
           'ggplot()' y en capas individuales.
      
           La lista de pares name-value se utiliza en la forma 'aesthetic =
           variable' y no requiere referencia al conjunto original de datos.
           Los nombres para las esteticas x e y son omitidos, pero todas las
           otras esteticas deben tener nombres. Esta función también
           estándariza los nombres de estética y traduce los antiguos nombres
           de R a los nombres de ggplot.
      
           Un objeto S7 que representa una lista con la clase 'mapping'. Los
           componentes de la lista son tanto variables como constantes.
      
      _Q_u_a_s_i_o_t_a_c_i_ó_n:
      
           La función 'aes()' es una función de citación. Esto significa que
           sus entradas se citan para ser evaluadas en el contexto de los
           datos. Esto facilita trabajar con variables desde la hoja de datos
           directamente, lo cual es fácil porque puedes nombrarlas
           directamente. Sin embargo, hay que usar citación quasialgebraica
           para programar con 'aes()'. Vea un tutorial sobre evaluación
           quasiquotativa como el vignette del paquete dplyr para aprender
           más sobre estos métodos.
      
      _N_o_t_e:
      
           Usando 'I()' para crear objetos de clase 'AsIs' hace que las
           escalas ignoren la variable y asuma que el valor enmohecido es un
           entrada directa al paquete gráfico. Ten en cuenta que las
           variables a veces se combinan, como en algunas estadísticas o
           ajustes de posición, que pueden producir resultados inesperados
           con variables 'AsIs'.
      
      _S_e_e _A_l_s_o:
      
           Las mapeamientos estéticos describen cómo las variables en los
           datos se mapifican a las propiedades visuales (estéticas) de
           geoms. Los mapeamientos estéticos pueden configurarse en
           'ggplot()' y en capas individuales.
      
           La lista de pares name-value se utiliza en la forma 'aesthetic =
           variable' y no requiere referencia al conjunto original de datos.
           Los nombres para las esteticas x e y son omitidos, pero todas las
           otras esteticas deben tener nombres. Esta función también
           estándariza los nombres de estética y traduce los antiguos nombres
           de R a los nombres de ggplot.
      
           'vars()' se utiliza para otra función de citas diseñada para
           especificaciones de faceting.
      
           Run 'vignette("ggplot2-specs")' para ver un resumen de otras
           estéticas que se pueden modificar.
      
           Evaluación retardada para trabajar con variables computadas.
      
           Otros estilos de documentación: 'aes_colour_fill_alpha',
           'aes_group_order', 'aes_linetype_size_shape', 'aes_position'.
      
      _E_x_a_m_p_l_e_s:
      
           aes(x = mpg, y = wt)
           aes(mpg, wt)
           
           # Puedes configurar los mapeos estéticos para que mappen las variables en tus datos a funciones de las propiedades visuales (estéticas) de los geoms.
           aes(x = mpg ^ 2, y = wt / cyl)
           
           # O para constantes
           aes(x = 1, colour = "smooth")
           
           # Los nombres de las estéticas se estandarizan automáticamente.
           aes(col = x)
           aes(fg = x)
           aes(color = x)
           aes(colour = x)
           
           # Aes se pasa a `ggplot()` o a capas individuales. Los estilos pasados se suministran al llamado de `aes()`.
           # Los mapeamientos estéticos describen cómo las variables en los datos se mapifican a las propiedades visuales (estéticas) de geoms. Los mapeamientos estéticos pueden configurarse en `ggplot()` y en capas individuales.
           
           La lista de pares name-value se utiliza en la forma `aesthetic = variable` y no requiere referencia al conjunto original de datos. Los nombres para las esteticas x e y son omitidos, pero todas las otras esteticas deben tener nombres. Esta función también estándariza los nombres de estética y traduce los antiguos nombres de R a los nombres de ggplot.
           
           Los mapeamientos estéticos toman como defaults para todos los capas dentro de `ggplot()`.
           ggplot(mpg, aes(displ, hwy)) + geom_point()
           ggplot(mpg) + geom_point(aes(displ, hwy))
           
           # La evaluación limpia (tidy evaluation) es un proceso en el que las variables se evalúan utilizando las funciones estándar del lenguaje y evitando el uso de la función de evaluación inmediata de R. Esto significa que las expresiones en R no deben utilizar la función `$` para acceder a los atributos de una estructura.
           # Las mapeamientos estéticos describen cómo las variables en los datos se mapifican a las propiedades visuales (estéticas) de geoms. Los mapeamientos estéticos pueden configurarse en `ggplot()` y en capas individuales.
           
           La lista de pares name-value se utiliza en la forma `aesthetic = variable` y no requiere referencia al conjunto original de datos. Los nombres para las esteticas x e y son omitidos, pero todas las otras esteticas deben tener nombres. Esta función también estándariza los nombres de estética y traduce los antiguos nombres de R a los nombres de ggplot.
           
           aes() automáticamente encasa todos sus argumentos, por lo que necesitas utilizar `tidy`
           # Los mapeamientos estéticos describen cómo las variables en los datos se mapifican a las propiedades visuales (estéticas) de geoms. Los mapeamientos estéticos pueden configurarse en `ggplot()` y en capas individuales.
           
           La lista de pares name-value se utiliza en la forma `aesthetic = variable` y no requiere referencia al conjunto original de datos. Los nombres para las esteticas x e y son omitidos, pero todas las otras esteticas deben tener nombres. Esta función también estándariza los nombres de estética y traduce los antiguos nombres de R a los nombres de ggplot.
           
            La evaluación crea conjuntos de accesorios alrededor de los flujos del ggplot2.
           # El caso más simple ocurre cuando tu envoltura toma puntos.
           scatter_by <- function(data, ...) {
             ggplot(data) + geom_point(aes(...))
           }
           scatter_by(mtcars, disp, drat)
           
           # Si tu envoltura tiene una interfaz más específica con argumentos nombrados,
           # Para configurar los mapeamientos estéticos, necesitas el operador "abrazo" (`+`).
           scatter_by <- function(data, x, y) {
             ggplot(data) + geom_point(aes({{ x }}, {{ y }}))
           }
           scatter_by(mtcars, disp, drat)
           
           # Los mapeamientos estéticos describen cómo las variables en los datos se mapifican a las propiedades visuales (estéticas) de geoms. Los mapeamientos estéticos pueden configurarse en `ggplot()` y en capas individuales.
           
           La lista de pares name-value se utiliza en la forma `aesthetic = variable` y no requiere referencia al conjunto original de datos. Los nombres para las esteticas x e y son omitidos, pero todas las otras esteticas deben tener nombres. Esta función también estándariza los nombres de estética y traduce los antiguos nombres de R a los nombres de ggplot.
           
           Nota que los usuarios de tu capa pueden utilizar sus propias funciones en lugar de esta función de mapeo por defecto.
           # Las mapeamientos estéticos describen cómo las variables en los datos se mapifican a las propiedades visuales (estéticas) de geoms. Los mapeamientos estéticos pueden configurarse en `ggplot()` y en capas individuales.
           
           La lista de pares name-value se utiliza en la forma `aesthetic = variable` y no requiere referencia al conjunto original de datos. Los nombres para las esteticas x e y son omitidos, pero todas las otras esteticas deben tener nombres. Esta función también estándariza los nombres de estética y traduce los antiguos nombres de R a los nombres de ggplot.
           
           Quedan expresiones citadas y todas resuelven como debería!
           cut3 <- function(x) cut_number(x, 3)
           scatter_by(mtcars, cut3(disp), drat)
           

# Interaction with LLM works

    Code
      lang_help("llm_classify", "mall", lang = "spanish", type = "text")
    Message
      v lang - Translation complete
    Output
      _C_a_t_e_g_o_r_i_z_e _d_a_t_a _a_s _o_n_e _o_f _o_p_t_i_o_n_s _g_i_v_e_n
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Use a Large Language Model (LLM) to classify the provided text as
           one of the options provided via the 'labels' argument.
      
      _U_s_a_g_e:
      
           llm_classify(
             .data,
             col,
             labels,
             pred_name = ".classify",
             additional_prompt = ""
           )
           
           llm_vec_classify(x, labels, additional_prompt = "", preview = FALSE)
           
      _A_r_g_u_m_e_n_t_s:
      
         .data: A 'data.frame' or 'tbl' object that contains the text to be
                analyzed
      
           col: The name of the field to analyze, supports 'tidy-eval'
      
        labels: A character vector with at least 2 labels to classify the
                text as
      
      pred_name: A character vector with the name of the new column where the
                prediction will be placed
      
      additional_prompt: Inserts this text into the prompt sent to the LLM
      
             x: A vector that contains the text to be analyzed
      
       preview: It returns the R call that would have been used to run the
                prediction. It only returns the first record in 'x'. Defaults
                to 'FALSE' Applies to vector function only.
      
      _V_a_l_u_e:
      
           'llm_classify' returns a 'data.frame' or 'tbl' object.
           'llm_vec_classify' returns a vector that is the same length as
           'x'.
      
      _E_x_a_m_p_l_e_s:
      
           library(mall)
           
           data("reviews")
           
           llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
           
           llm_classify(reviews, review, c("appliance", "computer"))
           
           # Use 'pred_name' to customize the new column's name
           llm_classify(
             reviews,
             review,
             c("appliance", "computer"),
             pred_name = "prod_type"
           )
           
           # Pass custom values for each classification
           llm_classify(reviews, review, c("appliance" ~ 1, "computer" ~ 2))
           
           # For character vectors, instead of a data frame, use this function
           llm_vec_classify(
             c("this is important!", "just whenever"),
             c("urgent", "not urgent")
           )
           
           # To preview the first call that will be made to the downstream R function
           llm_vec_classify(
             c("this is important!", "just whenever"),
             c("urgent", "not urgent"),
             preview = TRUE
           )
           

---

    Code
      lang_help("llm_classify", "mall", lang = "english", type = "text")
    Condition
      Error in `lang_help()`:
      ! Language already set to English, use `help()`

---

    Code
      lang_help("nothere", lang = "spanish", type = "text")
    Condition
      Error in `rd_find()`:
      ! Could not find `nothere`
      i Tip: Make sure the containing package is loaded, and the topic is spelled correctly

---

    Code
      lang_help("nothere", "notpkg", lang = "spanish", type = "text")
    Condition
      Error in `rd_find()`:
      ! Package `notpkg` not found
      i Tip: Make sure package name is spelled correctly

---

    Code
      lang_help("nothere", "mall", lang = "spanish", type = "text")
    Condition
      Error in `rd_find()`:
      ! `nothere` could not be found in `mall`
      i Tip: Make sure both are spelled correctly

