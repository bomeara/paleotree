#' Construct A Block of Tip Age Calibrations for Use with Tip-Dating Analyses in MrBayes
#' 
#' Takes a set of tip ages (in several possible forms, see below),
#' and outputs a set of tip age calibrations
#' for use with tip-dating analyses (sensu Zhang et al., 2016)
#' in the popular phylogenetics program \emph{MrBayes}.
#' These calibrations are printed as a set of character strings, as well as a 
#' line placing an offset exponential prior on the tree age, either
#' printed in the R console or in a named text file, which can be used as
#' commands in the \emph{MrBayes} block of a NEXUS file for use with 
#' (you guessed it!) \emph{MrBayes}.

#' @details
#' Beware: some combinations of arguments might not make sense for your data.
#' 
#' (But that's always true, is it not?)

#' @param tipTimes This input may be either a timeList object (i.e. a list of length 2, 
#' composed of a table of interval upper and lower time boundaries (i.e. earlier and latter bounds), and 
#' a table of first and last intervals for taxa) or a matrix with rownames
#' for taxa as you want listed in the MrBayes block, with either one, two
#' or four columns containing ages (respectively) for point occurrences with
#' precise dates (for a single column), uncertainty bounds on a point occurrence
#' (for two columns), or uncertainty bounds on the first and
#' last occurrence (for four columns). Note that precise first and last occurrence
#' dates should not be entered as a two column matrix, as this will instead be interpreted
#' as uncertainty bounds on a single occurrence. Instead, either select which you want to
#' use for tip-dates and give a 1-column matrix, or repeat (and collate) the columns, so that
#' the first and last appearances has uncertainty bounds of zero.

#' @param whichAppearance Which appearance date of the taxa should be used:
#' their \code{'first'} or their \code{'last'} appearance date? The default
#' option is to use the 'first' appearance date. Note that use of the last
#' appearance date means that tips will be constrained to occur before their
#' last occurrence, and thus could occur long after their first occurrence (!).

#' @param ageCalibrationType This argument decides how age calibrations are defined, 
#' and currently allows for four options: \code{"fixedDateEarlier"} which fixes tip
#' ages at the earlier (lower) bound for the selected age of appearance (see argument
#' \code{whichAppearance} for how that selection is made), \code{"fixedDateLatter"}
#' which fixes the date to the latter (upper) bound of the selected age of appearance,
#' \code{"fixedDateRandom"} which fixes tips to a date that is randomly drawn from a
#' uniform distribution bounded by the upper and lower bounds on the selected age of
#' appearance, or (the recommended option) \code{"uniformRange"} which places a uniform
#' prior on the age of the tip, bounded by the latest and earliest (upper and lower)
#' bounds on the the selected age.

#' @param treeAgeOffset A parameter given by the user controlling the offset 
#' between the minimum and expected tree age prior. mean tree age for the
#' offset exponential prior on tree age will be set to the minimum tree age, 
#' plus this offset value. Thus, an offset of 10 million years would equate to a prior
#' assuming that the expected tree age is around 10 million years before the minimum age.

#' @param minTreeAge if \code{NULL} (the default), then minTreeAge will
#' be set as the oldest date among the tip age used (those used being
#' determine by user choices (or oldest bound on a tip age). Otherwise,
#' the user can supply their own minimum tree, which must be greater than
#' whatever the oldest tip age used is.

#' @param collapseUniform MrBayes won't accept uniform age priors where the maximum and
#' minimum age are identical (i.e. its actually a fixed age). Thus, if this argument
#' is \code{TRUE} (the default), this function
#' will treat any taxon ages where the maximum and minimum are identical as a fixed age, and
#' will override setting \code{ageCalibrationType = "uniformRange"} for those dates.
#' All taxa with their ages set to fixed by the behavior of \code{anchorTaxon} or \code{collapseUniform}
#' are returned as a list within a commented line of the returned MrBayes block.

#' @param anchorTaxon This argument may be a logical (default is \code{TRUE}, or a character string of length = 1.
#' This argument has no effect if \code{ageCalibrationType} is not set to "uniformRange", but the argument may still be evaluated.
#' If \code{ageCalibrationType = "uniformRange"}, MrBayes will do a tip-dating analysis with uniform age uncertainties on 
#' all taxa (if such uncertainties exist; see \code{collapseUniform}). However, MrBayes does not record how each tree sits on an absolute time-scale,
#' so if the placement of \emph{every} tip is uncertain, lining up multiple dated trees sampled from the posterior (where each tip's true age might
#' differ) could be a nightmare to back-calculate, if not impossible. Thus, if \code{ageCalibrationType = "uniformRange"}, and there are no tip taxa given
#' fixed dates due to \code{collapseUniform} (i.e. all of the tip ages have a range of uncertainty on them), then a particular taxon
#' will be selected and given a fixed date equal to its earliest appearance time for its respective \code{whichAppearance}. This taxon can either be indicated by
#' the user or instead the first taxon listed in \code{tipTimes} will be arbitrary selected. All taxa with their ages set
#' to fixed by the behavior of \code{anchorTaxon} or \code{collapseUniform} are returned as a list within a commented line of the returned MrBayes block.

#' @param file Filename (possibly with path) as a character string
#' to a file which will be overwritten with the output tip age calibrations.
#' If \code{NULL}, tip calibration commands are output to the console.

#' @return
#' If argument \code{file} is \code{NULL}, then the tip age commands
#' are output as a series of character strings.
#' 
#' All taxa with their ages set to fixed by the behavior of \code{anchorTaxon} or \code{collapseUniform}
#' are returned as a list within a commented line of the returned MrBayes block.

#' @author
#' David W. Bapst. This code was produced as part of a project 
#' funded by National Science Foundation grant EAR-1147537 to S. J. Carlson.

#' @references
#' Zhang, C., T. Stadler, S. Klopfstein, T. A. Heath, and F. Ronquist. 2016. 
#' Total-Evidence Dating under the Fossilized Birth-Death Process.
#' \emph{Systematic Biology} 65(2):228-249. 

#' @seealso 
#' \code{\link{createMrBayesConstraints}}, \code{\link{createMrBayesTipDatingNexus}}

#' @examples
#' 
#' # load retiolitid dataset
#' data(retiolitinae)
#' 
#' # uniform prior, with a 10 million year offset for
#' 	# the expected tree age from the earliest first appearance
#' 
#' createMrBayesTipCalibrations(tipTimes = retioRanges, whichAppearance = "first",
#' 	ageCalibrationType = "uniformRange", treeAgeOffset = 10)
#' 
#' # fixed prior, at the earliest bound for the first appearance
#' 
#' createMrBayesTipCalibrations(tipTimes = retioRanges, whichAppearance = "first",
#' 	ageCalibrationType = "fixedDateEarlier", treeAgeOffset = 10)
#' 
#' # fixed prior, sampled from between the bounds on the last appearance
#' 	# you should probably never do this, fyi
#' 
#' createMrBayesTipCalibrations(tipTimes = retioRanges, whichAppearance = "first",
#' 	ageCalibrationType = "fixedDateRandom", treeAgeOffset = 10)
#' 
#' 
#' \dontrun{
#' 
#' createMrBayesTipCalibrations(tipTimes = retioRanges, whichAppearance = "first",
#' 	ageCalibrationType = "uniformRange", treeAgeOffset = 10, file = "tipCalibrations.txt")
#' 
#' }
#' 




#' @name createMrBayesTipCalibrations
#' @rdname createMrBayesTipCalibrations
#' @export
createMrBayesTipCalibrations <- function(tipTimes,
	ageCalibrationType,whichAppearance = "first",
	treeAgeOffset,minTreeAge = NULL,
	collapseUniform = TRUE,anchorTaxon = TRUE,file = NULL){
	#
	#
	#################################################################################################
	# make sure tipTimes is not a data.frame
	if(is.data.frame(tipTimes)){
		tipTimes <- as.matrix(tipTimes)
		}
	if(is.list(tipTimes)){
		if(length(tipTimes) == 2){
			tipTimes[[1]] <- as.matrix(tipTimes[[1]])
			tipTimes[[2]] <- as.matrix(tipTimes[[2]])
		}else{
			stop("why is tipTimes a list of not length 2?")
			}
		}
	#######################################################################################
	if(length(ageCalibrationType) != 1){
		stop("argument ageCalibrationType must be of length 1")
		}
	if(length(whichAppearance) != 1){
		stop("argument whichAppearance must be of length 1")
		}
	if(all(whichAppearance != c("first","last"))){
		stop("argument whichAppearance must be one of 'first' or 'last'")
		}
	if(all(ageCalibrationType != c(
		"fixedDateEarlier","fixedDateLatter",
		"fixedDateRandom","uniformRange"))){
			stop('argument ageCalibrationType must be one of 
				"fixedDateEarlier", "fixedDateLatter", "fixedDateRandom", or "uniformRange"')
		}
	if(length(treeAgeOffset) != 1){
		stop("treeAgeOffset must be of length 1")
		}
	if(!is.null(minTreeAge)){
		if(length(minTreeAge) != 1){
			stop("minTreeAge must be of length 1")
			}
		}
	
	#
	############################################
	# format tipTimes
	#
	#if list of two (i.e. timeList), convert to four-date format
	if(is.list(tipTimes) & length(tipTimes) == 2){
		tipTimes <- timeList2fourDate(tipTimes)
		}
	# checks for insanity in tipTimes
	if(!is.matrix(tipTimes)){
		stop("tipTimes must be of type matrix, or a list with a length of 2")
		}
	# coerce to numeric
	if(!is.numeric(tipTimes)){
		tipTimes2 <- apply(tipTimes,2,as.numeric)
		rownames(tipTimes2) <- rownames(tipTimes)
		tipTimes <- tipTimes2
		}
	# must be a table with 1, 2 or 4 columns
	if(all(ncol(tipTimes) != c(1,2,4))){
		stop("tipTimes must have 1 or 2 or 4 columns")
		}
	# Before we go any further, let's preserve the taxon names
	taxonNames <- rownames(tipTimes)
	#
	# check for things the user is unlikely to want to do
	if(ncol(tipTimes) == 1){
		if(ageCalibrationType != "fixedDateEarlier"){
			stop("You appear to be supplying a single point occurrence per taxon.
				There isn't any uncertainty or upper bounds on ages, so 
				ageCalibrationType should be set to 'fixedDateEarlier'")
			}
		}
	###########################################
	# test anchorTaxon
	if(length(anchorTaxon) != 1){
		stop("anchorTaxon must be of length 1")
		}
	# is anchorTaxon a logical?
	if(is.logical(anchorTaxon)){
		pickFix <- anchorTaxon
		# Does an anchorTaxon need to be picked?
		if(anchorTaxon & ageCalibrationType == "uniformRange"){
			# remember taxonNames[1] for later... might not become fixed though
			anchorTaxon <- taxonNames[1]
		}else{
			anchorTaxon <- NULL
			}
	}else{
		if(!is.character(anchorTaxon)){
			stop("anchorTaxon must be of type character if not logical")
			}
		pickFix <- FALSE
		# test that its a real taxon
		if(!any(anchorTaxon == taxonNames)){
			stop("anchorTaxon appears to be a taxon name, but not found among rownames (presumed taxon names) in tipTimes")
			}
		}
	####################################################################
	# fix so four columns
	# if two columns, then make four-date by repeating
	if(ncol(tipTimes) == 2){
		tipTimes <- cbind(tipTimes,tipTimes)
		}
	#if a single column of point ages, then repeat four times
	if(ncol(tipTimes) == 1){
		tipTimes <- cbind(tipTimes,tipTimes,tipTimes,tipTimes)
		}
	# check that tipTimes is now a matrix with 4 columns
	if(!is.matrix(tipTimes)){
		stop("tipTimes not coercing to matrix properly")
		}
	if(ncol(tipTimes) != 4){
		stop("tipTimes not coercing to four column format correctly")
		}
	if(!is.numeric(tipTimes)){
		stop("tipTimes not coercing to type numeric properly")
		}
	# -Add check to tip-Calibrate which makes sure age data is correctly ordered before using it
	misorderedTimes <- apply(tipTimes,1,function(z) diff(z[1:2]))>0.0001
	if(any(misorderedTimes)){
		#print(tipTimes)
		stop(paste0("dates in tipTimes do not appear to be correctly ordered from oldest to youngest: check ",
			paste0(rownames(tipTimes)[misorderedTimes],collapse = " ")))
		}
	#and the other pair of dates
	misorderedTimes <- apply(tipTimes,1,function(z) diff(z[3:4]))>0
	if(any(misorderedTimes)){
		stop(paste0("dates in tipTimes do not appear to be correctly ordered from oldest to youngest: check ",
			paste0(rownames(tipTimes)[misorderedTimes],collapse = " ")))
		}	
	#####################################################################
	# filter for whichAppearance
	# choose either the first or last appearance times
		# (these will likely often be identical)
	if(whichAppearance == "first"){
		tipTimes <- tipTimes[,1:2]
		}
	if(whichAppearance == "last"){
		tipTimes <- tipTimes[,3:4]
		}
	#check
	if(ncol(tipTimes) != 2){
		stop("Weird data format for tipTimes")
		}
	#
	#########################################################
	# select times
	# for converting to fixed or uniform age ranges
	#
	if(ageCalibrationType == "fixedDateEarlier"){
		# use lower bound for selected age of appearance
		tipTimes <- tipTimes[,1,drop = FALSE]
		timeType <- "fixed"
		}
	if(ageCalibrationType == "fixedDateLatter"){	
		# use upper bound for selected age of appearance
		tipTimes <- tipTimes[,2,drop = FALSE]
		timeType <- "fixed"
		}
	if(ageCalibrationType == "fixedDateRandom"){	
		# random drawn from a uniform distribution
		tipTimes <- t(t(apply(tipTimes,1,function(x) runif(1,x[2],x[1]))))
		timeType <- "fixed"
		}
	if(ageCalibrationType == "uniformRange"){
		# if uniform, don't need to edit tipTimes
		timeType <- "uniform"
		}
	# check
	if(all(timeType != c("fixed","uniform"))){
		stop("Problem when selecting ages. ageCalibrationType argument incorrect?")
		}
	# 
	##############################################
	# start writing MrBayes block
	if(timeType == "fixed"){
		#format fixed age script - single age per taxon
		dateBlock <- sapply(1:nrow(tipTimes),function(i)
			paste0("calibrate ",rownames(tipTimes)[i],
				" = fixed (",tipTimes[i],");"))
		}
	# use upper and lower bounds of selected age
		# of appearance to place uniform prior on tip age
	if(timeType == "uniform"){
		# format uniform age block - two ages per taxon
		# figure out which taxa will need to be fixed
		if(collapseUniform){
			# MrBayes doesn't like uniform ranges with the same max and min
					# related - cannot use uniform calibration is min == max, must use fixed!
			fixCollapse <- sapply(1:nrow(tipTimes),function(x)
				identical(tipTimes[x,2],tipTimes[x,1]))
		}else{
			fixCollapse <- rep(FALSE,nrow(tipTimes))
			}
		# fix anchor taxon
			# -Need to write code so that users are forced by default to constrain at least one
			# taxon to a precise time (an anchor taxon) for sake of accurately dating tree on absolute time-scale	
		if(pickFix){
			if(!any(fixCollapse)){
				message(paste0("anchorTaxon not user-defined, forcing ",
					anchorTaxon," to be a fixed tip age"))
				fixCollapse[rownames(tipTimes) == anchorTaxon] <- TRUE
				}
		}else{
			if(!is.null(anchorTaxon)){
				fixCollapse[rownames(tipTimes) == anchorTaxon] <- TRUE
				}
			}
		# now actually write the date block!
		dateBlock <- character(nrow(tipTimes))	
		for(i in 1:length(dateBlock)){
			if(fixCollapse[i]){
				dateBlock[i] <- paste0("calibrate ",rownames(tipTimes)[i],
					" = fixed (",tipTimes[i,1],");")
			}else{
				dateBlock[i] <- paste0("calibrate ",rownames(tipTimes)[i],
					" = uniform (",tipTimes[i,2],
					", ",tipTimes[i,1],");")
				}
			}
		# write line indicating fixed taxa
		if(any(fixCollapse)){
			fixedLine <- paste("[These taxa had fixed tip ages:",
				paste0(rownames(tipTimes)[fixCollapse],collapse = " "),"]")
		}else{
			fixedLine <- " "
			}
		# attach to date block
		dateBlock <- c(dateBlock,fixedLine)
		}
	#####################################################
	#need to create tree age prior
	# get minimum age of tips
	minTipAge <- max(tipTimes)
	if(is.null(minTreeAge)){
		minTreeAge <- minTipAge
	}else{
		# make sure minimum tree age is less than oldest tip
		if((minTreeAge*1.0001)<minTipAge){
			stop("User given minTreeAge is younger than the oldest tip age")
			}
		}
	#
	# use offset to calculate mean tree age
	meanTreeAge <- minTreeAge+treeAgeOffset
	#
	# write tree age prior command
	treeAgeBlock <- paste0("prset treeagepr = offsetexp(",
		minTreeAge,", ",meanTreeAge,");")
	########################################################
	# create final block for output
	#
	finalBlock <- c(dateBlock,"",treeAgeBlock)
	#
	if(!is.null(file)){
		write(finalBlock,file)
	}else{
		return(finalBlock)
		}
	}

