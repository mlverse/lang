# Interaction with LLM works

    Code
      lang_help("llm_classify", "mall", lang = "spanish", type = "text")
    Message
      Translating: 
      Translating: Title
    Output
      _C_a_t_e_g_o_r_i_z_e _d_a_t_a _a_s _o_n_e _o_f _o_p_t_i_o_n_s _g_i_v_e_n
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           Use a Large Language Model (LLM) to classify the provided text as
           oneof the options provided via the 'labels' argument.
      
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
                predictionwill be placed
      
      additional_prompt: Inserts this text into the prompt sent to the LLM
      
             x: A vector that contains the text to be analyzed
      
       preview: It returns the R call that would have been used to run the
                prediction.It only returns the first record in 'x'. Defaults
                to 'FALSE' Applies tovector function only.
      
      _V_a_l_u_e:
      
           'llm_classify' returns a 'data.frame' or 'tbl'
           object.'llm_vec_classify' returns a vector that is the same length
           as 'x'.
      
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
      lang_help("predict", "stats", lang = "spanish", type = "text")
    Message
      Translating: 
      Translating: Title
    Output
      _M_o_d_e_l _P_r_e_d_i_c_t_i_o_n_s
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           'predict' is a generic function for predictions from the results
           ofvarious model fitting functions.  The function invokes
           particular_methods_ which depend on the 'class' of the first
           argument.
      
      _U_s_a_g_e:
      
           predict(object, ...)
           
      _A_r_g_u_m_e_n_t_s:
      
        object: a model object for which prediction is desired.
      
           ...: additional arguments affecting the predictions produced.
      
      _D_e_t_a_i_l_s:
      
           Most prediction methods which are similar to those for linear
           modelshave an argument 'newdata' specifying the first place to
           look forexplanatory variables to be used for prediction.  Some
           considerableattempts are made to match up the columns in 'newdata'
           to those usedfor fitting, for example that they are of comparable
           types and that anyfactors have the same level set in the same
           order (or can betransformed to be so).
      
           Time series prediction methods in package 'stats' have an
           argument'n.ahead' specifying how many time steps ahead to predict.
      
           Many methods have a logical argument 'se.fit' saying if standard
           errorsare to be returned.
      
      _V_a_l_u_e:
      
           The form of the value returned by 'predict' depends on the class
           of itsargument.  See the documentation of the particular methods
           for detailsof what is produced by that method.
      
      _R_e_f_e_r_e_n_c_e_s:
      
           Chambers, J. M. and Hastie, T. J. (1992) _Statistical Models in
           S_.  Wadsworth & Brooks/Cole.
      
      _S_e_e _A_l_s_o:
      
           'predict.glm', 'predict.lm', 'predict.loess',
           'predict.nls','predict.poly', 'predict.princomp',
           'predict.smooth.spline'.
      
           SafePrediction for prediction from (univariable) polynomial and
           splinefits.
      
           For time-series prediction, 'predict.ar',
           'predict.Arima','predict.arima0', 'predict.HoltWinters',
           'predict.StructTS'.
      
      _E_x_a_m_p_l_e_s:
      
           require(utils)
           
           ## All the "predict" methods found
           ## NB most of the methods in the standard packages are hidden.
           ## Output will depend on what namespaces are (or have been) loaded.
           
           for(fn in methods("predict"))
              try({
                  f <- eval(substitute(getAnywhere(fn)$objs[[1]], list(fn = fn)))
                  cat(fn, ":\n\t", deparse(args(f)), "\n")
                  }, silent = TRUE)
           

