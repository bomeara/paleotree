% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/testEdgeMat.R
\name{testEdgeMat}
\alias{testEdgeMat}
\alias{cleanNewPhylo}
\alias{cleanTree}
\alias{cleanNewPhylo}
\title{Test the Edge Matrix of a '\code{phylo}' Phylogeny Object for Inconsistencies}
\usage{
testEdgeMat(tree)

cleanNewPhylo(tree)
}
\arguments{
\item{tree}{A phylogeny object of type \code{phylo}}
}
\value{
For \code{testEdgeMat}, if all the checks in the function pass correctly, the logical \code{TRUE} is returned.

For \code{cleanNewPhylo}, an object of class \code{phylo} is returned.
}
\description{
\code{testEdgeMat} is a small simple function which tests the \code{$edge} matrix of \code{phylo} objects for
inconsistencies that can cause downstream analytical problems.
The associated function, \code{cleanNewPhylo} puts an input
\code{phylo} object, presumably freshly created or reconstituted by some function, through a series
of post-processing, This includes having singles collapsed,
nodes reordered and being written out as a Newick string and read back in,
to ensure functionality with ape functions
and \code{ape}-derived functions.
}
\details{
Useful when doing complex manipulations and reconstitutions of \code{phylo} objects (or their
\emph{de novo} construction), and thus is used by a number of \code{paleotree} functions.
}
\examples{

set.seed(444)
tree <- rtree(10)
# should return TRUE
testEdgeMat(tree)

# should also work on star trees
testEdgeMat(stree(10))

# should also work on trees with two taxa
testEdgeMat(rtree(2))

# should also work on trees with one taxon
testEdgeMat(stree(1))

#running cleanNewPhylo on this tree should have little effect
		#beyond ladderizing it...
tree1 <- cleanNewPhylo(tree)

#compare outputs
layout(1:2)
plot(tree)
plot(tree1)
layout(1)
}
\author{
David W. Bapst, with a large number of tests incorporated from Emmanuel Paradis's \code{checkValidPhylo} function,
provided at his github repository here, which was released GPL v>2:

https://github.com/emmanuelparadis/checkValidPhylo
}
