# @file GetCovariates.R
#
# Copyright 2015 Observational Health Data Sciences and Informatics
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

#' Get covariate information from the database
#'
#' @description
#' Constructs a large set of covariates for one or more cohorts using data in the CDM schema.
#'
#' @details
#' This function uses the data in the CDM to construct a large set of covariates for the provided cohorts. The cohorts are assumed to be in a table
#' with the same structure as the cohort table in the OMOP CDM. The subject_id in this table must refer to person_ids in the CDM. One person can occurr 
#' multiple times, but the combination of subject_id and cohort_start_date is assumed to be unique.
#'
#' @param connectionDetails		An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param connection          A connection to the server containing the schema as created using the \code{connect} function in the \code{DatabaseConnector} package.
#' @param oracleTempSchema		A schema where temp tables can be created in Oracle.
#' @param cdmDatabaseSchema    The name of the database schema that contains the OMOP CDM instance.  Requires read permissions to this database. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.     	
#' @param useExistingCohortPerson  Does the temporary table \code{cohort_person} already exists? Can only be used when the \code{connection} parameter is not NULL.		
#' @param cohortDatabaseSchema 		If not using an existing \code{cohort_person} temp table, where is the source cohort table located? Note that on SQL Server, one should include both
#' the database and schema, e.g. "cdm_schema.dbo".
#' @param cohortTable 		    
#' @param cohortConceptIds 		  If not using an existing \code{cohort_person} temp table, what is the name of the source cohort table?
#' @template GetCovariatesParams
#' 
#' @return
#' Returns an object of type \code{covariateData}, containing information on the baseline covariates. Information about multiple outcomes can be captured at once for efficiency reasons. This object is a list with the following components:
#' \describe{
#'   \item{covariates}{An ffdf object listing the baseline covariates per person in the two cohorts. This is done using a sparse representation: covariates with a value of 0 are omitted to save space.}
#'   \item{covariateRef}{An ffdf object describing the covariates that have been extracted.}
#'   \item{metaData}{A list of objects with information on how the covariateData object was constructed.}
#' }
#' 
#' @export
getDbCovariates <- function(connectionDetails = NULL,
                            connection = NULL,
                            oracleTempSchema = NULL,
                            cdmDatabaseSchema,
                            useExistingCohortPerson = TRUE,
                            cohortDatabaseSchema = cdmDatabaseSchema,
                            cohortTable = "cohort",
                            cohortConceptIds = c(0,1),
                            useCovariateDemographics = TRUE,
                            useCovariateConditionOccurrence = TRUE,
                            useCovariateConditionOccurrence365d = TRUE,
                            useCovariateConditionOccurrence30d = FALSE,
                            useCovariateConditionOccurrenceInpt180d = FALSE,
                            useCovariateConditionEra = FALSE,
                            useCovariateConditionEraEver = FALSE,
                            useCovariateConditionEraOverlap = FALSE,
                            useCovariateConditionGroup = FALSE,
                            useCovariateDrugExposure = FALSE,
                            useCovariateDrugExposure365d = FALSE,
                            useCovariateDrugExposure30d = FALSE,
                            useCovariateDrugEra = FALSE,
                            useCovariateDrugEra365d = FALSE,
                            useCovariateDrugEra30d = FALSE,
                            useCovariateDrugEraOverlap = FALSE,
                            useCovariateDrugEraEver = FALSE,
                            useCovariateDrugGroup = FALSE,
                            useCovariateProcedureOccurrence = FALSE,
                            useCovariateProcedureOccurrence365d = FALSE,
                            useCovariateProcedureOccurrence30d = FALSE,
                            useCovariateProcedureGroup = FALSE,
                            useCovariateObservation = FALSE,
                            useCovariateObservation365d = FALSE,
                            useCovariateObservation30d = FALSE,
                            useCovariateObservationBelow = FALSE,
                            useCovariateObservationAbove = FALSE,
                            useCovariateObservationCount365d = FALSE,
                            useCovariateConceptCounts = FALSE,
                            useCovariateRiskScores = FALSE,
                            useCovariateInteractionYear = FALSE,
                            useCovariateInteractionMonth = FALSE,
                            excludedCovariateConceptIds = "",
                            deleteCovariatesSmallCount = 100) {
  cdmDatabase <- strsplit(cdmDatabaseSchema ,"\\.")[[1]][1]
  if (is.null(connectionDetails) && is.null(connection))
    stop("Either connectionDetails or connection has to be specified")
  if (!is.null(connectionDetails) && !is.null(connection))
    stop("Cannot specify both connectionDetails and connection")
  if (useExistingCohortPerson && is.null(connection))
    stop("When using an existing cohort temp table, connection must be specified")
  
  if (is.null(connection)){
    conn <- connect(connectionDetails)
  } else {
    conn <- connection
  }
  
  renderedSql <- SqlRender::loadRenderTranslateSql("GetCovariates.sql",
                                                   packageName = "CohortMethod",
                                                   dbms = attr(conn, "dbms"),
                                                   oracleTempSchema = oracleTempSchema,
                                                   cdm_database = cdmDatabase,
                                                   use_existing_cohort_person = useExistingCohortPerson,
                                                   cohort_database_schema = cohortDatabaseSchema,
                                                   cohort_table = cohortTable,
                                                   cohort_concept_ids = cohortConceptIds,
                                                   use_covariate_demographics = useCovariateDemographics,
                                                   use_covariate_condition_occurrence = useCovariateConditionOccurrence,
                                                   use_covariate_condition_occurrence_365d = useCovariateConditionOccurrence365d,
                                                   use_covariate_condition_occurrence_30d = useCovariateConditionOccurrence30d,
                                                   use_covariate_condition_occurrence_inpt180d = useCovariateConditionOccurrenceInpt180d,
                                                   use_covariate_condition_era = useCovariateConditionEra,
                                                   use_covariate_condition_era_ever = useCovariateConditionEraEver,
                                                   use_covariate_condition_era_overlap = useCovariateConditionEraOverlap,
                                                   use_covariate_condition_group = useCovariateConditionGroup,
                                                   use_covariate_drug_exposure = useCovariateDrugExposure,
                                                   use_covariate_drug_exposure_365d = useCovariateDrugExposure365d,
                                                   use_covariate_drug_exposure_30d = useCovariateDrugExposure30d,
                                                   use_covariate_drug_era = useCovariateDrugEra,
                                                   use_covariate_drug_era_365d = useCovariateDrugEra365d,
                                                   use_covariate_drug_era_30d = useCovariateDrugEra30d,
                                                   use_covariate_drug_era_overlap = useCovariateDrugEraOverlap,
                                                   use_covariate_drug_era_ever = useCovariateDrugEraEver,
                                                   use_covariate_drug_group = useCovariateDrugGroup,
                                                   use_covariate_procedure_occurrence = useCovariateProcedureOccurrence,
                                                   use_covariate_procedure_occurrence_365d = useCovariateProcedureOccurrence365d,
                                                   use_covariate_procedure_occurrence_30d = useCovariateProcedureOccurrence30d,
                                                   use_covariate_procedure_group = useCovariateProcedureGroup,
                                                   use_covariate_observation = useCovariateObservation,
                                                   use_covariate_observation_365d = useCovariateObservation365d,
                                                   use_covariate_observation_30d = useCovariateObservation30d,
                                                   use_covariate_observation_below = useCovariateObservationBelow,
                                                   use_covariate_observation_above = useCovariateObservationAbove,
                                                   use_covariate_observation_count365d = useCovariateObservationCount365d,
                                                   use_covariate_concept_counts = useCovariateConceptCounts,
                                                   use_covariate_risk_scores = useCovariateRiskScores,
                                                   use_covariate_interaction_year = useCovariateInteractionYear,
                                                   use_covariate_interaction_month = useCovariateInteractionMonth,
                                                   excluded_covariate_concept_ids = excludedCovariateConceptIds,
                                                   delete_covariates_small_count = deleteCovariatesSmallCount)
  
  writeLines("Executing multiple queries. This could take a while")
  DatabaseConnector::executeSql(conn,renderedSql)
  writeLines("Done")
  
  writeLines("Fetching data from server")
  start <- Sys.time()
  covariateSql <-"SELECT person_id, cohort_start_date, cohort_definition_id, covariate_id, covariate_value FROM #cohort_covariate ORDER BY person_id, covariate_id"
  covariateSql <- SqlRender::translateSql(covariateSql, "sql server", attr(conn, "dbms"), oracleTempSchema)$sql
  covariates <- DatabaseConnector::dbGetQuery.ffdf(conn, covariateSql)
  covariateRefSql <-"SELECT covariate_id, covariate_name, analysis_id, concept_id  FROM #cohort_covariate_ref ORDER BY covariate_id"
  covariateRefSql <- SqlRender::translateSql(covariateRefSql, "sql server", attr(conn, "dbms"), oracleTempSchema)$sql
  covariateRef <- DatabaseConnector::dbGetQuery.ffdf(conn, covariateRefSql)
  delta <- Sys.time() - start
  writeLines(paste("Loading took", signif(delta,3), attr(delta,"units")))
  
  renderedSql <- SqlRender::loadRenderTranslateSql("RemoveCovariateTempTables.sql",
                                                   packageName = "CohortMethod",
                                                   dbms = attr(conn, "dbms"),
                                                   oracleTempSchema = oracleTempSchema)
  DatabaseConnector::executeSql(conn,renderedSql, progressBar = FALSE, reportOverallTime = FALSE)
  if (is.null(connection)){
    dummy <- RJDBC::dbDisconnect(conn)
  }
  
  colnames(covariates) <- SqlRender::snakeCaseToCamelCase(colnames(covariates))
  colnames(covariateRef) <- SqlRender::snakeCaseToCamelCase(colnames(covariateRef))
  metaData <- list(sql = renderedSql,
                   call = match.call()
  )
  result <- list(covariates = covariates,
                 covariateRef = covariateRef,
                 metaData = metaData
  )
  #Open all ffdfs to prevent annoying messages later:
  if (nrow(result$covariates) == 0){
    warning("No data found")
  } else {
    open(result$covariates)
    open(result$covariateRef)
  }
  class(result) <- "covariateData"
  return(result)  
}