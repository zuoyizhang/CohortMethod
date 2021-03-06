# @file VignetteDataFetch.R
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

#' @keywords internal
.vignetteDataFetch <- function(){
  # This function should be used to fetch the data that is used in the vignettes.
  #library(SqlRender)
  #library(DatabaseConnector)
  #library(CohortMethod)
  #setwd("s:/temp")
  #setwd("c:/users/mschuemi/git/CohortMethod")
  
  # If ff is complaining it can't find the temp folder, use   options("fftempdir" = "s:/temp")
  
  pw <- NULL
  dbms <- "sql server"
  user <- NULL
  server <- "RNDUSRDHIT07.jnj.com"
  cdmDatabaseSchema <- "cdm_truven_mdcd.dbo"
  resultsDatabaseSchema <- "scratch.dbo"
  port <- NULL
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms=dbms, server = server, user = user, password = pw, port=port)
  sql <- loadRenderTranslateSql("coxibVsNonselVsGiBleed.sql", 
                                packageName = "CohortMethod", 
                                dbms = dbms,
                                cdmDatabaseSchema = cdmDatabaseSchema, 
                                resultsDatabaseSchema = resultsDatabaseSchema)
  
  connection <- DatabaseConnector::connect(connectionDetails)
  DatabaseConnector::executeSql(connection, sql)
  
  # Check number of subjects per cohort:
  sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @resultsDatabaseSchema.coxibVsNonselVsGiBleed GROUP BY cohort_definition_id"
  sql <- SqlRender::renderSql(sql, resultsDatabaseSchema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::querySql(connection, sql)
  
  # Get all NSAIDs:
  sql <- "SELECT concept_id FROM @cdmDatabaseSchema.concept_ancestor INNER JOIN @cdmDatabaseSchema.concept ON descendant_concept_id = concept_id WHERE ancestor_concept_id = 21603933"
  sql <- SqlRender::renderSql(sql, cdmDatabaseSchema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  nsaids <- DatabaseConnector::querySql(connection, sql)
  nsaids <- nsaids$CONCEPT_ID
  
  #Load data:
  cohortData <- getDbCohortData(connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                oracleTempSchema = resultsDatabaseSchema,
                                targetDrugConceptId = 1,
                                comparatorDrugConceptId = 2, 
                                indicationConceptIds = c(),
                                washoutWindow = 183, 
                                indicationLookbackWindow = 183,
                                studyStartDate = "", 
                                studyEndDate = "", 
                                exclusionConceptIds = nsaids,
                                outcomeConceptIds = 3, 
                                outcomeConditionTypeConceptIds = c(), 
                                exposureDatabaseSchema = resultsDatabaseSchema,
                                exposureTable = "coxibVsNonselVsGiBleed",
                                outcomeDatabaseSchema = resultsDatabaseSchema,
                                outcomeTable = "coxibVsNonselVsGiBleed",
                                useCovariateDemographics = TRUE,
                                useCovariateConditionOccurrence = TRUE,
                                useCovariateConditionOccurrence365d = TRUE,
                                useCovariateConditionOccurrence30d = TRUE,
                                useCovariateConditionOccurrenceInpt180d = TRUE,
                                useCovariateConditionEra = TRUE,
                                useCovariateConditionEraEver = TRUE,
                                useCovariateConditionEraOverlap = TRUE,
                                useCovariateConditionGroup = TRUE,
                                useCovariateDrugExposure = TRUE,
                                useCovariateDrugExposure365d = TRUE,
                                useCovariateDrugExposure30d = TRUE,
                                useCovariateDrugEra = TRUE,
                                useCovariateDrugEra365d = TRUE,
                                useCovariateDrugEra30d = TRUE,
                                useCovariateDrugEraEver = TRUE,
                                useCovariateDrugEraOverlap = TRUE,
                                useCovariateDrugGroup = TRUE,
                                useCovariateProcedureOccurrence = TRUE,
                                useCovariateProcedureOccurrence365d = TRUE,
                                useCovariateProcedureOccurrence30d = TRUE,
                                useCovariateProcedureGroup = TRUE,
                                useCovariateObservation = TRUE,
                                useCovariateObservation365d = TRUE,
                                useCovariateObservation30d = TRUE,
                                useCovariateObservationBelow = TRUE,
                                useCovariateObservationAbove = TRUE,
                                useCovariateObservationCount365d = TRUE,
                                useCovariateConceptCounts = TRUE,
                                useCovariateRiskScores = TRUE,
                                useCovariateInteractionYear = FALSE,
                                useCovariateInteractionMonth = FALSE,
                                excludedCovariateConceptIds = nsaids, 
                                excludeDrugsFromCovariates = FALSE,
                                deleteCovariatesSmallCount = 100)
  
  saveCohortData(cohortData,"c:/temp/vignetteCohortData")
  
  #vignetteSimulationProfile <- createCohortDataSimulationProfile(cohortData)
  #save(vignetteSimulationProfile, file = "vignetteSimulationProfile.rda")
  
  #cohortData <- loadCohortData("vignetteCohortData")
  #setwd("C:/Users/mschuemi/git/CohortMethod")
  ps <- createPs(cohortData,
                 outcomeConceptId = 3, 
                 checkSorting = FALSE, 
                 control = createControl(noiseLevel = "quiet",threads = 10)
  )
  vignettePs <- ps
  save(vignettePs, file = "data/vignettePs.rda", compress = "xz")
  
  #load("data/vignettePs.rda")
  #ps <- vignettePs
  #psTrimmed <- trimByPsToEquipoise(ps)  
  strata <- matchOnPs(ps, caliper = 0.25, caliperScale = "standardized", maxRatio = 1)
  vignetteBalance <- computeCovariateBalance(strata, cohortData, outcomeConceptId = 3)
  save(vignetteBalance,file = "data/vignetteBalance.rda", compress = "xz")
  
  #load("vignetteBalance.rda")
  
  outcomeModel <- fitOutcomeModel(outcomeConceptId = 3,
                                  cohortData = cohortData,
                                  riskWindowStart = 0, 
                                  riskWindowEnd = 30,
                                  addExposureDaysToEnd = TRUE,
                                  useCovariates = FALSE, 
                                  modelType = "cox",
                                  stratifiedCox = FALSE) 
  vignetteOutcomeModel1 <- outcomeModel
  save(vignetteOutcomeModel1, file = "data/vignetteOutcomeModel1.rda", compress = "xz")
  
  outcomeModel <- fitOutcomeModel(outcomeConceptId = 3,
                                  cohortData = cohortData,
                                  subPopulation = strata,
                                  riskWindowStart = 0, 
                                  riskWindowEnd = 30,
                                  addExposureDaysToEnd = TRUE,
                                  useCovariates = FALSE, 
                                  modelType = "cox",
                                  stratifiedCox = TRUE)
  vignetteOutcomeModel2 <- outcomeModel
  save(vignetteOutcomeModel2, file = "data/vignetteOutcomeModel2.rda", compress = "xz")
  
  outcomeModel <- fitOutcomeModel(outcomeConceptId = 3,
                                  cohortData = cohortData,
                                  subPopulation = strata,
                                  riskWindowStart = 0, 
                                  riskWindowEnd = 30,
                                  addExposureDaysToEnd = TRUE,
                                  useCovariates = TRUE, 
                                  modelType = "cox",
                                  stratifiedCox = TRUE)
  vignetteOutcomeModel3 <- outcomeModel
  save(vignetteOutcomeModel3, file = "data/vignetteOutcomeModel3.rda", compress = "xz")
  
}