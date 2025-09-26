# shim_lang_help works

    Code
      shim_lang_help("llm_classify", "mall", type = "text")
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
           

# shim_lang_question works

    Code
      shim_lang_question("llm_classify", "mall")

# Shim works as expected

    Code
      shim_lang_question(mall::llm_classify)

# Shim is able to be attached

    Code
      help(llm_classify)
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
      shim_lang_question(llm_classify)
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
           

# Conflicting language message shows up

    Code
      which_lang(choose = TRUE)
    Message
      i The `LANG` and `LANGUAGE` variables have different values.
        Will use value of `LANGUAGE`: "spanish"
        This message will only appear once during your session
    Output
      [1] "spanish"

