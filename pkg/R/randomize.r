#' Weighted mean calculated from randomized species attributes
#' 
#' Function applied on the object of class \code{wm}, which returns values of weighted mean calculated from randomized species attributes.
#' @param M object of the class \code{wm}
#' @param permutations number of randomizations
#' @param FUN function to be applied on the column of calculated weighted mean values
#' @param progress.bar logical value, should be the progress bar indicating the progress of the calculation launched?
#' @param parallel integer or NULL (default). If integer, calculation will be conducted in parallel on number of cores given by \code{parallel}
#' @param library.par character vector with libraries needed for application of function defined by \code{FUN} argument (to be exported into parallel process). Not necessary if the functions in \code{FUN} are stated explicitly (e.g. \code{vegan:::cca})
#' @param export.cl ??
#' @author David Zeleny (zeleny.david@@gmail.com)
#' @export
#' 

randomize <- function (...) UseMethod ('randomize')

#' @export
#' @rdname randomize
randomize.wm <- function (M, permutations = 1, FUN = function (x) x, progress.bar = F, parallel = NULL, library.par = NULL, export.cl = NULL)
{
  if (!is.wm (M)) stop ("Object M is not of class 'wm'")
  if (progress.bar & is.null (parallel)) win.pb <- winProgressBar(title = "Permutation progress bar", label = "", min = 0, max = permutations, initial = 0, width = 300)
  sitspe <- attr (M, 'sitspe')
  speatt <- attr (M, 'speatt')
  FUN1 <- function (x) wm (sitspe = sitspe[,!is.na(x)], speatt = sample (x[!is.na(x)]))
  if (is.null (parallel))
  {
    temp.result <- list ()
    for (perm in seq (1, permutations))
    {
      if (progress.bar) setWinProgressBar (win.pb, perm)
      temp.result[[perm]] <- apply (apply (speatt, 2, FUN = FUN1), 2, FUN)
    }
  }  
  
  if (!is.null (parallel))
  {
    require (parallel)
    cl <- makeCluster(parallel)
    clusterExport (cl, varlist = c("FUN", "FUN1", "speatt", "sitspe", "library.par"), envir = environment ())
    if (!is.null (export.cl)) clusterExport (cl, export.cl)
    if (!is.null (library.par)) clusterEvalQ (cl, eval (call ('library', library.par)))
    temp.result <- parLapply (cl, seq (1, permutations), fun = function (x)
    {
      apply (apply (speatt, 2, FUN = FUN1), 2, FUN)
    })
    stopCluster (cl)
  }
  if (progress.bar & is.null (parallel)) close (win.pb)
  if (permutations == 1) temp.result <- temp.result[[1]]
  return (temp.result)
}