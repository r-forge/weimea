#' @title Forest vegetation in deep river valley of Vltava (Czech Republic)
#' 
#' @description Datasets with species composition of forest vegetation, their species Ellenberg indicator values, species functional traits (compiled from databases only for herb species) and several measured environmental characteristics for each site. 
#' 
#' @details
#' 
#' Vegetation plots, located in even distances along transects following the steep valley slopes of Vltava river valley and collected during 2001-2003. Each transect started at the valley bottom and end up at the upper part of the valley slope. Plots are of the size 10x15 m. In each plot, all species of tree, shrub and herb layer were recorded and their abundances were estimated using 9-degree ordinal Braun-Blanquette scale (these values were consequently transformed into percentage values). At each plot, various topographical and soil factors were measured or estimated (see Table below). The dataset contains 27 transects with 97 samples.
#' 
#' For the purpose of the current dataset, species in shrub and tree layer have been merged, juveniles removed and nomenclature have been modified according to Kubat et al. (2002). Dataset has two parts: with all (tree, shrub and herb) species (\code{vltava$spe, $ell, $env} etc.) and with subset of only herb species (\code{vltava$herbs$spe, $ell, $traits etc.}). While Ellenberg indicator values are provided for both all and only herb species subset, plant functional traits are only for subset of herb species (it would perhaps not be meaningful to compare e.g. SLA or plant height for trees and herbs).
#' 
#' 
#' Environmental variables include:
#' \itemize{
#' \item ELEVATION Elevation [m a.s.l.]
#' \item SLOPE Inclination [degrees]
#' \item ASPSSW Aspect (expressed as deviation of plot aspect from 22.5 degrees; reaches the highest value for the supposedly warmest SSW aspect)
#' \item XERSSW Index of xericity = cos (aspect - 202.5) x tg (slope) (highest values for SSW slopes, which are supposed to be the warmest)
#' \item SURFSL Landform shape in the downslope direction (three-degree ordinal scale: -1 concave, 0 flat, 1 convex)
#' \item SURFIS Landform shape along an isohypse (three-degree ordinal scale: -1 concave, 0 flat, 1 convex)
#' \item LITHIC Presence of lithic leptosols (shallow soils near rock outcrops)
#' \item SKELETIC Presence of skeletic and hyperskeletic lepthosols (stony soils on scree accumulations)
#' \item CAMBISOL Presence of cambisols (well-developed zonal soils)
#' \item FLUVISOL Presence of fluvisols (water-influenced soils formed from alluvial deposits)
#' \item SOILDPT Depth of the soil [cm]
#' \item pH.H Soil pH (measured in water solution)
#' \item COVERE32 Sum of estimated cover of tree and shrub layer [percentage]
#' }
#' @usage data (vltava)
#'  @format
#'  \code{vltava} is a list with these items:
#'  \itemize{
#'  \item \code{spe} Compositional matrix of all species (sample x species, percentage cover scale)
#'  \item \code{ell} Species Ellenberg indicator values (species x Ellenberg values for light, temperature, continentality, moisture, reaction and nutrients, compiled from Ellenberg et al. 1991).
#'  \item \code{env} Environmental variables (see Details).
#'  \item \code{group} Classsification of the sample into one of four vegetation types using numerical classification (Ward's agglomerative clustering applied on Euclidean distances using log transformed compositional data about all species).
#'  \item \code{transect} Transect number (1-27).
#'  \item \code{spnames} Data frame with two columns: \code{Full.Species.Name} - original species names, and \code{Layer} - vegetation layer, in which the species occur (1 - herb layer, 23 - shrub or/and tree layer)
#'  \item \code{herbs} list with the following items, related only to the subset of herb species:
#'    \itemize{
#'    \item \code{spe} Compositional matrix of herb speices (sample x species, percentage cover scale)
#'    \item \code{ell} Species Ellenberg indicator values for herb species (species x Ellenberg values for light, temperature, continentality, moisture, reaction and nutrients)
#'    \item \code{traits} Species functional traits for plant height (compiled from Czech flora, Kubat et al. 2002), specific leaf area (SLA) and seed weight (compiled from LEDA database, Kleyer et al. 2008).
#'    \item \code{spnames} Data frame with two columns: \code{Full.Species.Name} - original species names, and \code{Layer} - vegetation layer, in which the species occur (1 - herb layer, 23 - shrub or/and tree layer)
#'  }}
 
#' 
#' @name vltava
#' @docType data
#' @author David Zeleny (\email{zeleny.david@@gmail.com})
#' @references
#' 
#' Ellenberg H., Weber H.E., Dull R., Wirth V., Werner W. & Paulissen D. 1991. Zeigerwerte von Pflanzen in Mitteleuropa. Scripta Geobotanica 18: 1-248.
#' 
#' Kleyer M., Bekker R.M., Knevel I.C., Bakker J.P., Tompson K., Sonnenshein M. et al. (2008) The LEDA Traitbase: a database of life-history traits of Northwest European flora. Journal of Ecology, 96, 1266-1274.
#' 
#' Kubat K., Hrouda L., Chrtek J. Jr., Kaplan Z., Kirschner J. & Stepanek J. (eds.) (2002) KliC ke kvetene Ceské Republiky (Key to the flora of the Czech Republic). Academia, Praha, Czech Republic.
#' 
#' Zeleny D. & Chytry M. (2007): Environmental control of vegetation pattern in deep river valleys of the Bohemian Massif. Preslia, 79: 205-222.
#' 
#' 
#' @keywords vltava.spe vltava.ell vltava.env
NULL