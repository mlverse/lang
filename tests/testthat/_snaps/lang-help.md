# Interaction with LLM works

    Code
      lang_help("llm_classify", "mall", lang = "spanish", type = "text")
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
      lang_help("lm", "stats", lang = "spanish", type = "text")
    Output
      _F_i_t_t_i_n_g _L_i_n_e_a_r _M_o_d_e_l_s
      
      _D_e_s_c_r_i_p_t_i_o_n:
      
           'lm' is used to fit linear models, including multivariate ones.
           It can be used to carry out regression, single stratum analysis of
           variance and analysis of covariance (although 'aov' may provide a
           more convenient interface for these).
      
      _U_s_a_g_e:
      
           lm(formula, data, subset, weights, na.action,
              method = "qr", model = TRUE, x = FALSE, y = FALSE, qr = TRUE,
              singular.ok = TRUE, contrasts = NULL, offset, ...)
           
           ## S3 method for class 'lm'
           print(x, digits = max(3L, getOption("digits") - 3L), ...)
           
      _A_r_g_u_m_e_n_t_s:
      
       formula: an object of class '"formula"' (or one that can be coerced to
                that class): a symbolic description of the model to be
                fitted.  The details of model specification are given under
                'Details'.
      
          data: an optional data frame, list or environment (or object
                coercible by 'as.data.frame' to a data frame) containing the
                variables in the model.  If not found in 'data', the
                variables are taken from 'environment(formula)', typically
                the environment from which 'lm' is called.
      
        subset: an optional vector specifying a subset of observations to be
                used in the fitting process.  (See additional details about
                how this argument interacts with data-dependent bases in the
                'Details' section of the 'model.frame' documentation.)
      
       weights: an optional vector of weights to be used in the fitting
                process.  Should be 'NULL' or a numeric vector.  If non-NULL,
                weighted least squares is used with weights 'weights' (that
                is, minimizing 'sum(w*e^2)'); otherwise ordinary least
                squares is used.  See also 'Details',
      
      na.action: a function which indicates what should happen when the data
                contain 'NA's.  The default is set by the 'na.action' setting
                of 'options', and is 'na.fail' if that is unset. The
                'factory-fresh' default is 'na.omit'.  Another possible value
                is 'NULL', no action.  Value 'na.exclude' can be useful.
      
        method: the method to be used; for fitting, currently only 'method =
                "qr"' is supported; 'method = "model.frame"' returns the
                model frame (the same as with 'model = TRUE', see below).
      
      model, x, y, qr: logicals.  If 'TRUE' the corresponding components of
                the fit (the model frame, the model matrix, the response, the
                QR decomposition) are returned.
      
      singular.ok: logical. If 'FALSE' (the default in S but not in R) a
                singular fit is an error.
      
      contrasts: an optional list. See the 'contrasts.arg' of
                'model.matrix.default'.
      
        offset: this can be used to specify an _a priori_ known component to
                be included in the linear predictor during fitting.  This
                should be 'NULL' or a numeric vector or matrix of extents
                matching those of the response.  One or more 'offset' terms
                can be included in the formula instead or as well, and if
                more than one are specified their sum is used.  See
                'model.offset'.
      
           ...: For 'lm()': additional arguments to be passed to the low
                level regression fitting functions (see below).
      
        digits: the number of significant digits to be passed to format (
                coef (x), .) when #1 'print()'ing print () ing.
      
      _D_e_t_a_i_l_s:
      
           Models for 'lm' are specified symbolically.  A typical model has
           the form 'response ~ terms' where 'response' is the (numeric)
           response vector and 'terms' is a series of terms which specifies a
           linear predictor for 'response'.  A terms specification of the
           form 'first + second' indicates all the terms in 'first' together
           with all the terms in 'second' with duplicates removed.  A
           specification of the form 'first:second' indicates the set of
           terms obtained by taking the interactions of all terms in 'first'
           with all terms in 'second'.  The specification 'first*second'
           indicates the _cross_ of 'first' and 'second'.  This is the same
           as 'first + second + first:second'.
      
           If the formula includes an 'offset', this is evaluated and
           subtracted from the response.
      
           If 'response' is a matrix a linear model is fitted separately by
           least-squares to each column of the matrix and the result inherits
           from '"mlm"' ("multivariate linear model").
      
           See 'model.matrix' for some further details.  The terms in the
           formula will be re-ordered so that main effects come first,
           followed by the interactions, all second-order, all third-order
           and so on: to avoid this pass a 'terms' object as the formula (see
           'aov' and 'demo(glm.vr)' for an example).
      
           A formula has an implied intercept term.  To remove this use
           either 'y ~ x - 1' or 'y ~ 0 + x'.  See 'formula' for more details
           of allowed formulae.
      
           Non-'NULL' 'weights' can be used to indicate that different
           observations have different variances (with the values in
           'weights' being inversely proportional to the variances); or
           equivalently, when the elements of 'weights' are positive integers
           w_i, that each response y_i is the mean of w_i unit-weight
           observations (including the case that there are w_i observations
           equal to y_i and the data have been summarized). However, in the
           latter case, notice that within-group variation is not used.
           Therefore, the sigma estimate and residual degrees of freedom may
           be suboptimal; in the case of replication weights, even wrong.
           Hence, standard errors and analysis of variance tables should be
           treated with care.
      
           'lm' calls the lower level functions 'lm.fit', etc, see below, for
           the actual numerical computations.  For programming only, you may
           consider doing likewise.
      
           All of 'weights', 'subset' and 'offset' are evaluated in the same
           way as variables in 'formula', that is first in 'data' and then in
           the environment of 'formula'.
      
      _V_a_l_u_e:
      
           lm returns an object of class "lm" or for multivariate ( multiple
           ) responses of class c("mlm", "lm") .  The functions summary and
           anova are used to obtain and print a summary and analysis of
           variance table of the results.  The generic accessor functions
           coefficients , effects , fitted.values and residuals extract
           various useful features of the value returned by lm .  An object
           of class "lm" is a list containing at least the following
           components: coefficients a named vector of coefficients residuals
           the residuals, that is response minus fitted values.
           fitted.values the fitted mean values.  rank the numeric rank of
           the fitted linear model.  weights (only for weighted fits) the
           specified weights.  df.residual the residual degrees of freedom.
           call the matched call.  terms the terms object used.  contrasts
           (only where relevant) the contrasts used.  xlevels (only where
           relevant) a record of the levels of the factors used in fitting.
           offset the offset used (missing if none were used).  y if
           requested, the response used.  x if requested, the model matrix
           used.  model if requested (the default), the model frame used.
           na.action (where relevant) information returned by model.frame on
           the special handling of NA s.  In addition, non-null fits will
           have components assign , effects and (unless not requested) qr
           relating to the linear fit, for use by extractor functions such as
           summary and effects .
      
      _U_s_i_n_g _t_i_m_e _s_e_r_i_e_s:
      
           Considerable care is needed when using 'lm' with time series.
      
           Unless 'na.action = NULL', the time series attributes are stripped
           from the variables before the regression is done.  (This is
           necessary as omitting 'NA's would invalidate the time series
           attributes, and if 'NA's are omitted in the middle of the series
           the result would no longer be a regular time series.)
      
           Even if the time series attributes are retained, they are not used
           to line up series, so that the time shift of a lagged or
           differenced regressor would be ignored.  It is good practice to
           prepare a 'data' argument by 'ts.intersect(..., dframe = TRUE)',
           then apply a suitable 'na.action' to that data frame and call 'lm'
           with 'na.action = NULL' so that residuals and fitted values are
           time series.
      
      _A_u_t_h_o_r(_s):
      
           The design was inspired by the S function of the same name
           described in Chambers (1992).  The implementation of model formula
           by Ross Ihaka was based on Wilkinson & Rogers (1973).
      
      _R_e_f_e_r_e_n_c_e_s:
      
           Chambers, J. M. (1992) _Linear models._ Chapter 4 of _Statistical
           Models in S_ eds J. M. Chambers and T. J. Hastie, Wadsworth &
           Brooks/Cole.
      
           Wilkinson, G. N. and Rogers, C. E. (1973).  Symbolic descriptions
           of factorial models for analysis of variance.  _Applied
           Statistics_, *22*, 392-399.  doi:10.2307/2346786
           <https://doi.org/10.2307/2346786>.
      
      _S_e_e _A_l_s_o:
      
           'summary.lm' for more detailed summaries and 'anova.lm' for the
           ANOVA table; 'aov' for a different interface.
      
           The generic functions 'coef', 'effects', 'residuals', 'fitted',
           'vcov'.
      
           'predict.lm' (via 'predict') for prediction, including confidence
           and prediction intervals; 'confint' for confidence intervals of
           _parameters_.
      
           'lm.influence' for regression diagnostics, and 'glm' for
           *generalized* linear models.
      
           The underlying low level functions, 'lm.fit' for plain, and
           'lm.wfit' for weighted regression fitting.
      
           More 'lm()' examples are available e.g., in 'anscombe',
           'attitude', 'freeny', 'LifeCycleSavings', 'longley', 'stackloss',
           'swiss'.
      
           'biglm' in package 'biglm' for an alternative way to fit linear
           models to large datasets (especially those with many cases).
      
      _E_x_a_m_p_l_e_s:
      
           require(graphics)
           
           ## Annette Dobson (1990) "An Introduction to Generalized Linear Models".
           ## Page 9: Plant Weight Data.
           ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
           trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
           group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
           weight <- c(ctl, trt)
           lm.D9 <- lm(weight ~ group)
           lm.D90 <- lm(weight ~ group - 1) # omitting intercept
           
           anova(lm.D9)
           summary(lm.D90)
           
           opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
           plot(lm.D9, las = 1)      # Residuals, Fitted, ...
           par(opar)
           
           ### less simple examples in "See Also" above
           

