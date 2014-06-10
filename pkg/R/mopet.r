#' Modified permutation test with weighted mean of species attributes
#' 
#' Function performing modified permutation test to calculate significance of relationship between weighted mean of species attributes and other variables.
#' 
#' @name mopet
#' @param M An object of the class \code{wm} 
#' @param env Vector or matrix with variables. See details.
#' @param method Statistical method used to analyse the relationship between M (of class \code{wm} and env), partial match to \code{'lm'}, \code{'aov'}, \code{'cor'}, \code{'kruskal'} and \code{'slope'}.
#' @param cor.coef Correlation coefficient in case of \code{method = 'cor'}. Partial match to 'pearson', 'spearman' and 'kendal'.
#' @param dependence Should M be dependent variable and env independent (\code{'M ~ env'}), or opposite? Applicable only for \code{method = 'lm'}. Partial match to \code{'M ~ env'} and \code{'env ~ M'}, so to write \code{dep = 'M'} is enough.
#' @param permutations Number of permutations.
#' @param test Which test should be conducted? Partial match between \code{'modified'}, \code{'standard'} and \code{both}.
#' @param parallel NULL (default) or integer number. Number of cores for parallel calculation of modified permutation test. Maximum number of cores should correspond to number of available cores on the processor.

#' @export
#' @examples 
#' data (vltava)
#' mean.eiv <- wm (vltava$spe, vltava$ell)
#' mopet (mean.eiv, vltava$env$pH.H, perm = 49, test = 'both')
#' mopet (mean.eiv, vltava$env$pH.H, perm = 49, test = 'stand', method = 'cor', cor.coef = 'spearm')
#' summary (mopet (mean.eiv, vltava$group, perm = 49, method = 'krusk'))
#' @details
#' Currently implemented statistical methods are correlation (\code{'cor'}), linear regression (\code{method = 'lm'}), ANOVA (\code{'aov'}) and Kruskal-Wallis test (\code{'kruskal'}).
#'
#' Argument \code{env} can be vector or matrix with one column. Only in case of linear regression (\code{method = 'lm'}) is possible to use matrix with several variables, which will be all used as independent variables in the model. For ANOVA and Kruskal-Wallis test, make sure that 'env' is \code{factor} (warning will be returned if this is not the case, but the calculation will be conducted). 
#' 
#' Difference between \code{method = 'lm'} and \code{'aov'} is in the format of summary tables, returned by \code{summary.mopet} function. In case of 'aov', this summary is expressed in the traditional language of ANOVA rather than linear models.
#' 
#' Both \code{method = 'lm'} and \code{'slope'} are based on linear regression and calculated by function \code{\link{lm}}, but differ by test statistic: while 'lm' is using F value and is testing the strength of the regression (measured by r2), 'slope' is using the slope of the regression line (b). This statistic is added here for comparison with the fourth corner method. While r2 (and r) is influenced by the issue of compositional autocorrelation, slope of regression is not.
#' 
#' Specific issue related to weighted mean is the case of missing species attributes. In current implementation, species with missing species attributes are removed from sample x species matrix prior to permutation of species attributes among species. 
#' @return  Function \code{mopet} returns list of the class \code{"mopet"}, which contains the following items:
#' \itemize{
#'  \item \code{real.summaries} summary of the method
#'  \item \code{coefs} model coefficients
#'  \item \code{stat} test statistic
#'  \item \code{orig.P} P-values from the original (parametric) test
#'  \item \code{perm.P} P-values from the not-modified permutation test (permuted are the whole rows of matrix M)
#'  \item \code{modif.P} P-values from the modified permutation test (permuted are species attributes in object M)
#'  \item \code{permutations} number of permutations
#'  }
#' @seealso \code{\link{wm}}

#' @export
mopet <- function (M, env, method = c('lm'), cor.coef = c('pearson'), dependence = "M ~ env", permutations = 499, test = "modified", parallel = NULL)
{
    METHOD <- c('lm', 'aov', 'cor', 'kruskal', 'slope')
    COR.COEF <- c('pearson', 'spearman', 'kendall')
    TEST <- c('standard', 'modified', 'both')
    DEPENDENCE <- c("M ~ env", "env ~ M")
    method <- match.arg (method, METHOD)
    cor.coef <- match.arg (cor.coef, COR.COEF)
    test <- match.arg (test, TEST)
    dependence <- match.arg (dependence, DEPENDENCE)
    if (!is.wm (M) & (test == "modified" || test == "both")) stop ("Object M must be of 'wm' class")
    if (method == 'cor' & dim (as.matrix (env))[2] > 1) stop ("For correlation, argument 'env' must contain only one variable")
    env <- as.matrix (env)
    sweeping.sign <- if (method == 'cor' & cor.coef == 'spearman') "<=" else ">="
    perm.P <- NULL
    modif.P <- NULL
    sitspe = attr (M, 'sitspe')
    fun <-  switch (method, 
              lm = if (dependence == 'M ~ env') expression (lm (M ~ env)) else expression (lm (env ~ M)),
              aov = expression (aov (M ~ env)),
              cor = expression (cor.test (M, env, method = cor.coef)),
              kruskal = expression (kruskal.test (M, env)),
              slope = expression (lm (M ~ env, weights = rowSums (sitspe))))
    summ <- switch (method,
                    lm = expression (summary (obj)),
                    aov = expression (summary (obj)),
                    cor = expression (obj), 
                    kruskal = expression (obj),
                    slope = expression (summary (obj)))
    coefs <- switch (method, 
                    lm = expression (coef (obj)),
                    aov = expression (coef (obj)),
                    cor = expression (obj$estimate),
                    kruskal = expression (obj$parameter),
                    slope = expression (coef (obj)))
    stat <- switch (method,
                    lm = expression ({temp <- anova (obj)$"F value"[1]; names (temp) <- "F value"; temp}),
                    aov = expression ({temp <- summary (obj)[[1]]$"F value"[1]; names (temp) <- "F value"; temp}),
                    cor = expression (obj$statistic),
                    kruskal = expression (obj$statistic),
                    slope = expression ({temp <- coef (summary (obj))[2,1]; names (temp) <- "b"; temp}))
    signi <- switch (method,
                    lm = expression (anova (obj)$"Pr(>F)"[1]),
                    aov = expression (summary (obj)[[1]]$"Pr(>F)"[1]),
                    cor = expression (obj$p.value),
                    kruskal = expression (obj$p.value),
                    slope = expression (coef (summary (obj))[2,4]))
    tail <- switch (method,
                     lm = 'one',
                     aov = 'one',
                     cor = 'two',
                     kruskal = 'one',
                     slope = 'two')
    res.real.fun <- if (dependence == 'M ~ env') apply (as.matrix (M), 2, FUN = function (i) with (list (M = i, env = env), eval (fun))) else apply (as.matrix (env), 2, FUN = function (i) with (list (env = i, M = as.matrix (M)), eval (fun)))
    real.summaries <- lapply (res.real.fun, FUN = function (obj) with (obj, eval (summ)))
    coefs <- lapply (res.real.fun, FUN = function (obj) with (obj, eval (coefs)))
    orig.P <- unlist (lapply (res.real.fun, FUN = function (obj) with (obj, eval (signi))))
    res.real.stat <- lapply (res.real.fun, FUN = function (obj) with (obj, eval (stat)))
    
    if (test == 'modified' || test == 'both') 
      {
      res.temp.stat.modif <-  if (dependence == 'M ~ env')  randomize (M, permutations = permutations, parallel = parallel, FUN = function (mat) lapply (apply (as.matrix (mat), 2, FUN = function (i) with (list (M = i, env = env), eval (fun))), FUN = function (obj) with (obj, eval (stat)))) else
        randomize (M, permutations = permutations, parallel = parallel, FUN = function (mat) lapply (apply (as.matrix (env), 2, FUN = function (i) with (list (env = i, M = as.matrix (mat)), eval (fun))), FUN = function (obj) with (obj, eval (stat)))) 
      res.temp.stat.modif <- rbind (matrix (unlist (res.temp.stat.modif), nrow = length (res.temp.stat.modif), byrow = T), unlist (res.real.stat))      
      modif.P <- (colSums (sweep (
        if (tail == 'one') res.temp.stat.modif else abs (res.temp.stat.modif), 2,
        if (tail == 'one') unlist (res.real.stat) else abs (unlist (res.real.stat)), sweeping.sign)))/(permutations+1)
      }
    
    if (test == 'standard' || test == 'both')
      {
      res.temp.stat.stand <- if (dependence == 'M ~ env') lapply (lapply (1:permutations, FUN = function (i) as.matrix (M)[sample (nrow (M)),]), FUN = function (mat) lapply (apply (as.matrix (mat), 2, FUN = function (i) with (list (M = i, env = env), eval (fun))), FUN = function (obj) with (obj, eval (stat)))) else
        lapply (lapply (1:permutations, FUN = function (i) as.matrix (M)[sample (nrow (M)),]), FUN = function (mat) lapply (apply (as.matrix (env), 2, FUN = function (i) with (list (env = i, M = as.matrix (mat)), eval (fun))), FUN = function (obj) with (obj, eval (stat))))
      res.temp.stat.stand <- rbind (matrix (unlist (res.temp.stat.stand), nrow = length (res.temp.stat.stand), byrow = T), unlist (res.real.stat))      
      perm.P <- (colSums (sweep (
        if (tail == 'one') res.temp.stat.stand else abs (res.temp.stat.stand), 2,
        if (tail == 'one') unlist (res.real.stat) else abs (unlist (res.real.stat)), sweeping.sign)))/(permutations+1)
      }
        
    result <- list (real.summaries = real.summaries, coefs = coefs, stat = res.real.stat, orig.P = orig.P, perm.P = perm.P, modif.P = modif.P, permutations = permutations)
    
    class (result) <- 'mopet'
    return (result)
}

#' @export
#' @rdname mopet
print.mopet <- function (object, digits = 3)
{
  symnum.pval <- function (pval) symnum( pval, corr = FALSE, na = FALSE, cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", "**", "*", ".", " "))
  mat.coef <- matrix (format (unlist (object$coefs), digits = digits), byrow = T, nrow = length (object$coefs))
  colnames (mat.coef) <- names(object$coefs[[1]])
  mat.stat <- matrix (format (unlist (object$stat), digits = digits))
  colnames (mat.stat) <- names (object$stat[[1]])
  if (!is.null (object$orig.P)) mat.orig.P <- cbind (orig.P = format.pval (object$orig.P, digits = digits), symnum.pval (object$orig.P))
  if (!is.null (object$perm.P)) mat.perm.P <- cbind (perm.P = format.pval (object$perm.P, digits = digits), symnum.pval (object$perm.P))
  if (!is.null (object$modif.P)) mat.modif.P <- cbind (modif.P = format.pval (object$modif.P, digits = digits), symnum.pval (object$modif.P))
  print.default (cbind (mat.coef, mat.stat, if (!is.null (object$orig.P)) mat.orig.P, if (!is.null (object$perm.P)) mat.perm.P, if (!is.null (object$modif.P)) mat.modif.P), quote = F, right = T)
}

#' @export
#' @rdname mopet
summary.mopet <- function (object)
{
  len <- length (object$real.summaries)
  cat ('\nSummary of mopet function:\n\n')
  for (i in seq (1, len))
  {
    cat ('\nOriginal result for variable', names (object$real.summaries)[i], ':\n')
    print (object$real.summaries[[i]])
    cat ('\n------------------------------------------------')
    if (!is.null (object$perm.P[i])) cat ('\nStandard permutation test: P = ', object$perm.P[i])
    if (!is.null (object$modif.P[i]))cat ('\nModified permutation test: P = ', object$modif.P[i])
    cat ('\nPermutation results based on', object$permutations, 'permutations')
    cat ('\n************************************************\n')
  }
  
}