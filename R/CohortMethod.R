# @file CohortMethod.R
#
# Copyright 2014 Observational Health Data Sciences and Informatics
#
# This file is part of CohortMethod
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Observational Health Data Sciences and Informatics
# @author Patrick Ryan
# @author Marc Suchard
# @author Martijn Schuemie

#' CohortMethod
#' 
#' @docType package
#' @name CohortMethod
#' @importFrom Rcpp evalCpp
#' @importFrom SqlRender loadRenderTranslateSql translateSql
#' @importFrom RJDBC dbDisconnect
#' @importFrom survival survfit Surv
#' @import bit
#' @import Cyclops
#' @import DatabaseConnector
#' @useDynLib CohortMethod
NULL

#' A simulation profile
#' @docType data
#' @keywords datasets
#' @name cohortDataSimulationProfile
#' @usage data(cohortDataSimulationProfile)
NULL

#' Propensity scores for the vignette
#' @docType data
#' @keywords datasets
#' @name vignettePs
#' @usage data(vignettePs)
NULL

#' Balance data for the vignette
#' @docType data
#' @keywords datasets
#' @name vignetteBalance
#' @usage data(vignetteBalance)
NULL

#' Outcome data for the vignette
#' @docType data
#' @keywords datasets
#' @name vignetteOutcomeModel1
#' @usage data(vignetteOutcomeModel1)
NULL

#' Outcome data for the vignette
#' @docType data
#' @keywords datasets
#' @name vignetteOutcomeModel2
#' @usage data(vignetteOutcomeModel2)
NULL

#' Outcome data for the vignette
#' @docType data
#' @keywords datasets
#' @name vignetteOutcomeModel3
#' @usage data(vignetteOutcomeModel3)
NULL

.onLoad <- function(libname, pkgname) {
  # Copied this from the ff package:
  if (is.null(getOption("ffmaxbytes"))){
    # memory.limit is windows specific
    if (.Platform$OS.type=="windows")
    {
      if (getRversion()>="2.6.0")  # memory.limit was silently changed from 2.6.0 to return in MB instead of bytes
        options(ffmaxbytes=0.5*utils::memory.limit()*(1024^2))
      else
        options(ffmaxbytes=0.5*utils::memory.limit())
    } else {
      # some magic constant
      options(ffmaxbytes=0.5*1024^3)
    }
  }
  
  #Workaround for problem with ff on machines with lots of memory (see https://github.com/edwindj/ffbase/issues/37)
  options(ffmaxbytes = min(getOption("ffmaxbytes"), .Machine$integer.max * 12))
}

#' @keywords internal
runCohortMethod <- function(){
  #todo: implement function that will call all other functions needed to run a cohort method study
}
