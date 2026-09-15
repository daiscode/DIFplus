#' This function creats contigency tables.
#' @name ContigencyTables
#' @aliases ContigencyTables
#' @title Function to create contigency tables
#' @description This function creates contigency tables by strata for each item. Both dichotomous and polytomous item responses are allowed.
#' It also handles missing responses and returns a cleaned data set with no missing data. 
#' @param Response.data A scored item responses matrix in the form of matrix or data frame. This matrix should not include any
#' other variables (group, stratum, cluser, etc.).
#' @param Response.code A numerical vector of all possible item responses. By default, Response.code=c(0,1).
#' @param Group The variable of group membership (e.g., gender). Its length should be equal to the sample size of the item response matrix.
#' @param group.names Names for each defined group (e.g., c('Male','Female')). This argument is optional. By default, group.names=NULL.
#' If not provided, group names of "Group.1, Group.2, etc." will be automatically generated.
#' @param Stratum The matching variable. By default, Stratum=NULL. If not provided, the observed total score will be used.
#' @param Cluster The cluster variable. Its length should be equal to the sample size of the item response matrix. By default, Cluster=NULL.
#' This variable will not be used to generate contigency tables. It will be included in the returned data set for DIF analysis.
#' @param missing.code Indication of how missing values were defined in the data. By default, missing.code="NA".
#' @param missing.impute The approach selected to handle missing item responses. By default, missing.impute="LW", indicating the list-wise
#' deletion will be used. Other options include: "PM" (person mean or row mean imputation),"IM" (item mean or column mean imputation), 
#' "TW" (two-way imputation), "LR" (logistic regression imputation), and EM (EM imputation). Check the package "TestDataImputation" 
#' (\url{https://cran.r-project.org/package=TestDataImputation}) for more details. \cr
#' Note. If any missing data are detected on group, cluster, or stratum variables, listwise deletion will be used before handling missing item responses.
#' @param print.information Indicator of whether function running information is printed on screen. By default, print.information=TRUE.
#' @return A list of strata statistcs, contigency tables, etc. 
#' \item{Strata.stats}{Summary statistics for each item: n.valid.strata, n.valid.category, and also sample sizes for each stratum across items.}
#' \item{c.table.list.all}{A list that contains all contigency tables across items and strata.}
#' \item{c.table.list.valid}{A list that contains only valid contigency tables across items and strata. 
#' Strata that have missing item response categories or zero marginal means are removed.}
#' \item{data.out}{A cleaned data set with variables "Group",  "Group.factor","Cluster", "Stratum", 
#' and all item responses (with missing data handled).}
#' @import stats
#' @import TestDataImputation
#' @import plyr
#' @usage ContigencyTables (Response.data, Response.code=c(0,1), 
#' Group, group.names=NULL, Stratum=NULL, Cluster=NULL, 
#' missing.code="NA",missing.impute="LW", print.information=TRUE)
#' @examples
#' #Specify the item responses matrix
#' data(data.adult)
#' Response.data<-data.adult[,2:13]
#' #Run the function with specifications      
#' c.table.out<-ContigencyTables(Response.data, Response.code=c(0,1), 
#'                               Group=data.adult$Group, group.names=NULL, 
#'                               Stratum=NULL, Cluster=NULL, missing.code="NA", 
#'                               missing.impute= "LW",print.information = TRUE)
#' #Obtain results
#' c.tables.all<-c.table.out$c.table.list.all
#' c.tables.valid<-c.table.out$c.table.list.valid
#' c.table.out$Strata.stats
#' data.use<-c.table.out$data.out
#' @export  
#' @usage ContigencyTables (Response.data, Response.code=c(0,1), 
#'        Group, group.names=NULL, Stratum=NULL, Cluster=NULL, 
#'        missing.code="NA", missing.impute="LW", print.information=TRUE)

ContigencyTables<-function (Response.data, Response.code=c(0,1), Group, group.names=NULL, 
                    Stratum=NULL, Cluster=NULL, missing.code="NA", 
                    missing.impute="LW", print.information=TRUE) {
  
  if (is.null(group.names)) {
    group.names<-paste("Group.",seq(1,nlevels(factor(Group))),sep='')
    Group.factor<-base::ordered(Group, labels = group.names)
  } else {
    Group.factor<-base::ordered(Group, labels = group.names)
    }
  Group<-as.data.frame(Group)
  Group.factor<-as.data.frame(Group.factor)
  Responses<-as.data.frame(Response.data)
  Group.var.name<-names(Group)

  if (!(is.null(Stratum))) {
    Stratum<-as.data.frame(Stratum)
    Stratum.var.name<-names(Stratum)
  } else {Stratum.var.name<-NULL}
  
  if (!(is.null(Cluster))) {
    Cluster<-as.data.frame(Cluster)
    Cluster.var.name<-names(Cluster)
    Cluster.delete<-F
  } else {
    Cluster<-Group
    Cluster.delete<-T
  }

    if (is.null(Stratum)) {
    if ((nrow(Responses)!=nrow(Group))) {
      warning ("Number of subjects are not equal to the number of data rows.",
               call. = FALSE)}
  } else {
    if ((nrow(Stratum) != nrow(Group)) |(nrow(Stratum)!= nrow(Responses))|(nrow(Responses)!=nrow(Group))) {
    warning ("Number of subjects are not equal to the number of data rows.",
             call. = FALSE)}
  }
  
    if (is.null(Stratum)) {
      data.1<-data.frame(Group, Group.factor,Cluster, Responses)
      names(data.1)[1:3]<-c('Group', 'Group.factor', "Cluster")
    } else {data.1<-data.frame(Group, Group.factor,Cluster, Stratum, Responses)
    names(data.1)[1:4]<-c('Group', 'Group.factor','Cluster', 'Stratum')
    }

    if (is.null(data.1$Stratum)) {
    data.2<-data.1[which(!is.na(data.1$Group)),]
  } else {data.2<-data.1[which(!is.na(data.1$Group) & !is.na(data.1$Stratum)),]
  }
  
  missing<-sapply(Responses, function(x) sum(is.na(x)))
  
  if (sum(missing) != 0 & print.information==TRUE) {
    print (paste("Missing item responses are detected and will be imputed with ",missing.impute, ".",rep=''))}

    if (missing.impute=="LW") {
    data.nomiss<-na.omit(data.2)
  } else {
    if (is.null(data.2$Stratum)) {
      response.nomiss<-ImputeTestData(Responses, missing.code, max.score = max(Response.code), missing.impute)
      data.nomiss<-data.frame(data.2[,1:3],response.nomiss)
      } else {      
      response.nomiss<-ImputeTestData(Responses, missing.code, max.score = max(Response.code), missing.impute)
      data.nomiss<-data.frame(data.2[,1:4],response.nomiss)
    }
  }
  
  if (is.null(data.nomiss$Stratum)) {
    Stratum<-rowSums(data.nomiss[,4:ncol(data.nomiss)],na.rm=T)
    data.use<-data.frame(data.nomiss[,1:3],Stratum, data.nomiss[,4:(ncol(data.nomiss))])
  }  else {
    data.use<-data.nomiss
  }
  
  Responses<-data.use[,-c(1:4)]
  Group<-data.use[,1]
  Group.factor<-data.use[,2]
  Cluster<-data.use[,3]
  Stratum<-data.use[,4]

  Stratum.sizes<-table(Stratum) 
  Strata.stats<-matrix(NA, ncol(Responses)+1,length(as.numeric(levels(factor(Stratum))))+2 )
  colnames(Strata.stats)<-c("n.valid.strata","n.valid.category",names(Stratum.sizes))
  rownames(Strata.stats)<-c("Overall",colnames(Responses))
  
  Stratum.values<-as.numeric(levels(factor(Stratum)))
  Strata.stats[1,3:ncol(Strata.stats)]<-Stratum.sizes 
  Strata.stats[1,1]<-Num.Stratum<-length(Stratum.sizes)
  Strata.stats[1,2]<-Num.category<-length(Response.code)
 
  Group.codes<-as.numeric(rownames(table(Group)))
  
  c.table.list.all<-c.table.list.valid<-rep(list(NA),ncol(Responses))

  for (j in 1:ncol(Responses)) { 
    c.table.list.valid.k<-c.table.list.k<-rep(list(NA),Num.Stratum)
    names(c.table.list.valid.k)<-names(c.table.list.k)<-paste("Stratum ", Stratum.values, sep='')

    data.j<-data.frame(Group,Group.factor, Stratum,Responses[,j])
    item.code<-as.numeric(levels(factor(Responses[,j])))
    
    Strata.stats[j+1,2]<-length(item.code)
    
    if (!(length(item.code) == length(Response.code)) & print.information==TRUE) {
      print (paste ("Item ", colnames(Responses)[j], ' showed missing response categories.',sep=''))}

    for (k in 1:Num.Stratum) { 
      
      data.k<-base::subset(data.j, Stratum==Stratum.values[k])
      colnames(data.k)[4]<-"Item"
      item.code.k<-rownames(table(data.k[,4]))
      if (!(length(item.code.k) == length(Response.code)) & print.information==TRUE) {
        print(paste ("Item ", colnames(Responses)[j], " Stratum ", Stratum.values[k]," showed missing response categories.", sep=''))}
      
      C.table.k<-matrix(NA,length(item.code.k)+1,length(Group.codes)+1)
      colnames(C.table.k)<-c(levels(Group.factor),"Total")
      row.names(C.table.k)<-c(paste("Response ",item.code.k,rep=''),"Total")
      
      crosstab.k<-table(data.k$Item,data.k$Group)

      C.table.k[1:length(item.code.k),1:length(Group.codes)]<-crosstab.k
      C.table.k[1:length(item.code.k),length(Group.codes)+1]<-rowSums(crosstab.k)
      C.table.k[length(item.code.k)+1,1:length(Group.codes)]<-colSums(crosstab.k)
      C.table.k[length(item.code.k)+1,length(Group.codes)+1]<-sum(crosstab.k)
     
      Strata.stats[j+1,2+k]<-sum(crosstab.k)
      
      c.table.list.valid.k[[k]]<- c.table.list.k[[k]]<-C.table.k
      
      if ((length(rowSums(crosstab.k))==1 & print.information==TRUE)|(sum(colSums(crosstab.k)==0)>0 & print.information==TRUE)){
        c.table.list.valid.k[[k]]<-NA
        Strata.stats[j+1,2+k]<-NA
        print (paste( "Item ",colnames(Responses)[j]," Stratum ",k, " showed zero marginal means.",sep=''))
      } else if ((length(rowSums(crosstab.k))==1 & print.information==FALSE)|(length(rowSums(crosstab.k))==1 & print.information==FALSE)){
        c.table.list.valid.k[[k]]<-NA
        Strata.stats[j+1,2+k]<-NA
      }
    } 
    
    c.table.list.all[[j]]<-c.table.list.k
    c.table.list.valid[[j]]<-c.table.list.valid.k[!is.na(c.table.list.valid.k)]
    Strata.stats[j+1,1]<-length(c.table.list.valid[[j]])
    
  } 
  
  names(c.table.list.valid)<-names(c.table.list.all)<-paste("Item ",colnames(Responses),sep='')
  
  if (is.null(Stratum.var.name)) {
    Stratum.var.name<-"Stratum"
  }
  
  if (Cluster.delete==T) {
    data.out<-data.use[,-3]
    names(data.out)[c(1,3)]<-c(Group.var.name,Stratum.var.name)
  } else {
    data.out<-data.use
    names(data.out)[c(1,3:4)]<-c(Group.var.name,Cluster.var.name,Stratum.var.name)
  }
  
  return( list(Strata.stats=Strata.stats,
              c.table.list.all=c.table.list.all, 
              c.table.list.valid=c.table.list.valid,
              data.out=data.out)) }