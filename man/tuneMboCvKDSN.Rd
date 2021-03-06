\name{tuneMboCvKDSN}
\alias{tuneMboCvKDSN}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Tuning of KDSN with efficient global optimization and cross-validation
}
\description{
Implements the efficient global optimization algorithm based on Kriging for kernel deep stacking networks (KDSN). This function uses cross-validation to calculate the desing grid and is more computationally expensive, but uses more accurate generalization error estimates.
}
\usage{
tuneMboCvKDSN(y, X, maxLevels=10, 
fineTuneIt=100, nStepMult=20, designMult=10, 
dimMax=round(sqrt(dim(X)[1])/2), addInfo=TRUE, nCores=1,
maxRuns=3, repetitions=5, tol_input=.Machine$double.eps^0.25,
cvIndex, lossFunc=devStandard)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
\item{y}{
Response matrix with one column.
}
\item{X}{
Design matrix. All factors must be already encoded.
}
\item{maxLevels}{
Maximum number of levels for the kernel deep stacking network (integer scalar).
}
\item{fineTuneIt}{
Number of drawn random weight matrices in fine tuning (integer scalar).
}
\item{nStepMult}{
Multiplier, which affects how many steps the EGO algorithm is run, depending on the number of parameters to estimate.
}
\item{designMult}{
Multiplier, which affects how many initial design points are evaluated in the loss function, depending on the number of parameters to estimate.
}
\item{dimMax}{
Maximal dimension of the random Fourier transformation. The effective number of parameters is dimMax*2. The default heuristic depends on the sample size.
}
\item{addInfo}{
Should additional information be printed during estimation? Default is TRUE.
}
\item{nCores}{
Number of threads for computing initial designs of model-based optimization and fine tuning in parallel mode. The cluster ist set up using package parallel. Default is serial mode with nCores=1.
}
\item{maxRuns}{
Maximal number of iterations in the conditional one dimensional optimization. Default is three. See \code{\link{optimize1dMulti}}.
}
\item{repetitions}{
Maximal number of random starting values in the conditional one dimensional optimization to avoid local optima. Default is five. See \code{\link{optimize1dMulti}}.
}
\item{tol_input}{
Convergence criteria of each one dimensional sub-optimization. Higher values will be more accurate, but require much more function evaluations. Default is the fourth root of the machine double accuracy. See \code{\link{optimize1dMulti}}.
}
\item{cvIndex}{
Index of cross-validation indices. The indices represent the training data. Must be supplied as list, the required format is identical to the output of the \code{\link[caret]{createFolds}} with argument returnTrain=TRUE. 
}
\item{lossFunc}{
Specifies how the loss on the test data should be evaluated. Defaults to predictive deviance \code{\link{devStandard}}.
}
}
\details{
The direct tuning algorithm (see for reference \code{\link{tuneKDSN}}) is adapted to surrogate model optimization. The algorithm is similiar and uses a model-based optimization procedure.
}

%return(list(par=c(ego_result), value=attr(ego_result, "funcVal")))

\value{
Gives the best tuned kernel deep stacking network of class \code{KDSN}.
}

%\references{
%}

\author{
Thomas Welchowski \email{welchow@imbie.meb.uni-bonn.de}
}

\note{
The performance of the model-based optimization increases with higher values of nStepMult and designMult. The computation time of the tuning algorithm increases mostly with higher values of dimMax.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link[DiceKriging]{km}}, \code{\link[DiceKriging]{leaveOneOut.km}}, \code{\link[lhs]{maximinLHS}}, \code{\link{tuneKDSN}}, \code{\link{mboAll}}, \code{\link{mbo1d}}, \code{\link{tuneMboLevelKDSN}}
}

\examples{
# Generate small sample of 20 observations of a binary classification task
# Due to keeping the example as fast as possible, the parameters of the tuning 
# algorithm are set for low accuracy. Higher values of tol_input, fineTuneIt, 
# maxRuns, repetitions will increase performance considerably.
library(pROC)

# Generate design matrix
sampleSize <- 20
X <- matrix(0, nrow=sampleSize, ncol=5)
for(j in 1:5) {
  set.seed (j)
  X [, j] <- rnorm(sampleSize)
}

# Generate response of binary problem with sum(X) > 0 -> 1 and 0 elsewhere
set.seed(-1)
error <- rnorm (sampleSize)
y <- ifelse((rowSums(X) + error) > 0, 1, 0)

# Generate test data
Xtest <- matrix(, nrow=sampleSize, ncol=5)
for(j in 1:5) {
  set.seed (j*2+1)
  Xtest [, j] <- rnorm(sampleSize)
}

# Generate test response
set.seed(-10)
error <- rnorm (sampleSize)
ytest <- ifelse((rowSums(Xtest) + error) > 0, 1, 0)

# Draw cv training indices
library(caret)
cvTrainInd <- createFolds(y=y, k = 2, list = TRUE, returnTrain = TRUE)

# Define loss function as auc
library(pROC)
defLossFunc <- function(preds, ytest) {-c(auc(response=ytest, predictor=c(preds)))}

# Tune kernel deep stacking network
\dontrun{
tuned_KDSN_EGO_CV <- tuneMboCvKDSN (y=y, X=X, 
maxLevels=2, fineTuneIt=10, nStepMult=2, designMult=5,
cvIndex=cvTrainInd, lossFunc=defLossFunc)
preds <- predict(tuned_KDSN_EGO_CV, newx=Xtest)
auc(response=ytest, predictor=c(preds))
}
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ models & regression }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line