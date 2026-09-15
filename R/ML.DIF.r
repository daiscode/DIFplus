#' This main function computes both unadjusted and adjusted Mantel-Haenszel statistics in the presence of multilevel data.
#' @name ML.DIF
#' @aliases ML.DIF
#' @title Main function to compute adjusted Mantel-Haenszel statistics
#' @description This main function computes both unadjusted and adjusted MH statistics 
#' in the presence of clustered data based on Begg (1999) <doi:10.1111/j.0006-341X.1999.00302.x>, Begg & Paykin (2001) 
#' <doi:10.1080/00949650108812115>, and French & Finch (2013) <doi: 10.1177/0013164412472341>. 
#' @param Response.data A scored item responses matrix in the form of matrix or data frame. This matrix should not include any
#' other variables (group, stratum, cluser, etc.).
#' @param Response.code A numerical vector of all possible item responses. By default, Response.code=c(0,1).
#' @param Cluster The cluster variable. Its length should be equal to the sample size of the item response matrix.
#' @param Group The variable of group membership (e.g., gender). Its length should be equal to the sample size of the item response matrix.
#' @param group.names Names for each defined group (e.g., c('Male','Female')). This argument is optional. By default, group.names=NULL.
#' If not provided, group names of "Group.1, Group.2, etc." will be automatically generated.
#' @param Stratum The matching variable. By default, Stratum=NULL. If not provided, the observed total score will be used.
#' @param correct.factor The value of adjustment applied to the adjusted MH statistic (i.e., f). The default value used here is .85. 
#' The adjusted MH statistic was found to exhibit low statistical power for DIF detection in some conditions. One solution to this 
#' is to reduce the magnitude of f through multiplying it by the correct factor (e.g., .85, .90, .95). The value of .85 is suggested by
#' French & Finch (2013) <doi: 10.1177/0013164412472341>. 
#' @param missing.code Indication of how missing values were defined in the data. By default, missing.code="NA".
#' @param missing.impute The approach selected to handle missing item responses. By default, missing.impute="LW", indicating the list-wise
#' deletion will be used. Other options include: "PM" (person mean or row mean imputation),"IM" (item mean or column mean imputation), 
#' "TW" (two-way imputation), "LR" (logistic regression imputation), and EM (EM imputation). Check the package "TestDataImputation" 
#' (\url{https://cran.r-project.org/package=TestDataImputation}) for more details. \cr
#' Note: If any missing data are detected on group, cluster, or stratum variables, listwise deletion will be used before handling missing item responses.
#' @param anchor.items A scored item responses matrix of selected anchor items. This matrix should be a subset of the response data matrix
#' specified above. By default, anchor.items=NULL.          
#' @param purification True of false argument, indicating whether purification will be used. By default, purification=FALSE. \cr
#' Note: Purification will not be applied if anchor items are specified and/or the matching variable is defined.                                           
#' @param max.iter The maximum number of iterations for purification. The default value is 10. 
#' @param alpha The alpha value used to decide on the DIF items. The default value is .05. 
#' @return A list of MH statistcs, contigency tables, etc.
#' \item{MH.values}{Summary of estimated MH statistics and corresponding p-values. Specifically, \cr
#'  * MH.unadj is the unadjusted MH test statistic.\cr
#'  * MH.score is the MH statistic based on working score test (Begg, 1999).\cr
#'  * MH.GMH is the MH test statistic based on Holland & Thayer's (1998) formula. \cr
#'  * MH.Yates is the MH.GMH statistic with Yates' correction. \cr
#'  * MH.adj is the adjusted MH statistic for clustered data; \cr
#'  * f.adj is the adjustment value based on Begg (1999). \cr
#'  * f.adj.correct is the product of f and the correction factor (.85, etc.). \cr 
#'  * DIF.Item (Yes) = 1 indicates the item is flagged as a DIF item;\cr
#'  * N.Valid, N.Strata, and N.Cluster refer to the sample size, number of valid stata and cluster that are used in the analysis.}
#' \item{Stratum.statistics}{summary statistics for each item: n.valid.strata, n.valid.category, 
#' and also sample sizes for each stratum across items.}
#' \item{c.table.list.all}{A list that contains all contigency tables across items and strata.}
#' \item{c.table.list.valid}{A list that contains only valid contigency tables across items and strata. 
#' Strata that have missign item response categories
#' or zero marginal means are removed.}
#' \item{data.out}{A cleaned data set with variables "Group",  "Group.factor","Cluster", "Stratum", 
#' and all item responses (with missing data handled).}
#' @import stats
#' @import TestDataImputation
#' @import plyr
#' @examples
#' #Specify the item responses matrix
#' data(data.adult)
#' Response.data<-data.adult[,2:13]
#' #Run the function with specifications      
#' ML.DIF.out<-ML.DIF (Response.data, Response.code=c(0,1),Cluster=data.adult$Cluster, 
#' Group=data.adult$Group, group.names=c('Reference','Focal'), 
#' Stratum=NULL, correct.factor=0.85, 
#' missing.code="NA", missing.impute="LW",
#' anchor.items=NULL, purification=FALSE,
#' max.iter=10, alpha = .05)
#' #Obtain results
#' ML.DIF.out$MH.values
#' ML.DIF.out$Stratum.statistics
#' @export  
#' @references {
#' Begg, M. D. (1999). 
#' "Analyzing k (2 × 2) Tables Under Cluster Sampling."
#'  Biometrics, 55(1), 302-307. doi:10.1111/j.0006-341X.1999.00302.x. 
#' }
#' @references {
#' Begg, M. D. & Paykin, A. B.  (2001). 
#' "Performance of and software for a modified mantel-haenszel statistic for correlated data."
#'  Journal of Statistical Computation and Simulation, 70(2), 175-195. doi:10.1080/00949650108812115.
#' }
#' @references {
#' French, B. F. & Finch, W. H. (2013). 
#' "Extensions of Mantel-Haenszel for Multilevel DIF Detection."
#'  Educational and Psychological Measurement, 73(4), 648-671. 
#'  doi:10.1177/0013164412472341.
#' }
#' @references {
#' Holland, P. W. & Thayer, D. T. (1988). 
#' "Differential item performance and the Mantel-Haenszel procedure."
#'  In H. Wainer & H. I. Braun (Eds.), Test validity (pp.129-145). Lawrence Erlbaum Associates, Inc.
#' }
#' @usage ML.DIF (Response.data, Response.code=c(0,1),Cluster, Group, 
#'        group.names=NULL, Stratum=NULL, correct.factor=0.85, 
#'        missing.code="NA", missing.impute="LW", 
#'        anchor.items=NULL, purification=FALSE, 
#'        max.iter=10, alpha = .05)

ML.DIF<-function (Response.data, Response.code=c(0,1),Cluster, Group, group.names=NULL, 
                  Stratum=NULL, correct.factor=0.85, 
                  missing.code="NA", missing.impute="LW",
                  anchor.items=NULL, purification=FALSE, 
                  max.iter=10, alpha = .05) {
  
  n.category=length(Response.code)
  
  if (n.category==2) {
    
    if (is.null(anchor.items)) {
      c.table.out<-ContigencyTables(Response.data, Response.code, Group, group.names, 
                                    Stratum, Cluster, missing.code, missing.impute,
                                    print.information = T)
      c.tables.all<-c.table.out$c.table.list.all
      c.tables.valid<-c.table.out$c.table.list.valid
      Stratum.statistics<-c.table.out$Strata.stats
      data.use<-c.table.out$data.out} else {
        anchor.names<-names(anchor.items)
        item.use.names<-names(Response.data) %in% anchor.names
        Response.data.1<-Response.data[!item.use.names]
        c.table.out<-ContigencyTables(Response.data.1, Response.code, Group, group.names, 
                                      Stratum, Cluster, missing.code, missing.impute)
        c.tables.all<-c.table.out$c.table.list.all
        c.tables.valid<-c.table.out$c.table.list.valid
        Stratum.statistics<-c.table.out$Strata.stats
        data.use<-c.table.out$data.out
      }
    
    Group.use<-data.use[,1]
    Group.factor.use<-data.use[,2]
    Cluster.use<-data.use[,3]
    Stratum<-data.use[,4]
    
    if ((!is.null(anchor.items)) & (purification==T)){ 
      warning ("Purification is allowed only when observed total score is used as Stratum and no anchor items specified! 
No DIF analysis conducted.", call. = FALSE)
      MH.values=NULL
      
    } else if ((!is.null(anchor.items)) & (purification==F)) {
      
      anchor.names<-names(anchor.items)
      item.use.names<-names(Response.data) %in% anchor.names
      Responses.use<-Response.data[!item.use.names]
      
      Cluster.values<-as.numeric(levels(factor(data.use$Cluster)))
      Cluster.sizes<-table(data.use$Cluster)
      Num.cluster<-length(Cluster.sizes)
      Max.cluste.size<-max(Cluster.sizes)
      Min.cluster.size<-min(Cluster.sizes)
      
      Stratum.values<-as.numeric(levels(factor(data.use$Stratum)))
      Stratum.sizes<-table(data.use$Stratum) 
      Num.Stratum<-length(Stratum.sizes)
      Max.Stratum.size<-max(Stratum.sizes)
      Min.Stratum.size<-min(Stratum.sizes)
      
      strata.mat <- matrix(0, nrow=nrow(data.use), ncol=Num.Stratum)
      ifelse ((min(Stratum.values)==0), Strata.temp<-data.use$Stratum+1, Strata.temp<-data.use$Stratum)
      
      Stratum.temp<-plyr::mapvalues(data.use$Stratum, from=as.numeric(Stratum.values), 
                                    to=seq(1,Num.Stratum),warn_missing = TRUE)
      strata.mat[cbind(seq(Stratum.temp), Stratum.temp)] <- 1
      colnames(strata.mat)<-names(Stratum.sizes)
      
      #-------------------------------------------------------------
      MH.values<-matrix(NA,ncol(Response.data),16)
      item.select.idx<-match(names(Responses.use),names(Response.data))
      to.print<-F
      
      for (j in item.select.idx) { 
        
        
        c.table.list<-(c.tables.valid[[which(item.select.idx==j)]])
        MH.temp<-matrix(NA,length(c.table.list),5)
        
        for (k in 1:length(c.table.list)) {
          
          c.table.k<-c.table.list[[k]]
          
          n.k<-c.table.k[-nrow(c.table.k),ncol(c.table.k)]
          m.k<-c.table.k[nrow(c.table.k),-ncol(c.table.k)]
          t.k<-c.table.k[nrow(c.table.k),ncol(c.table.k)]
          
          a.k<-c.table.k[-nrow(c.table.k),2]
          b.k<-c.table.k[-nrow(c.table.k),1]
          
          if (length(a.k)==2) {
            MH.temp[k,1]<-a.k[2]-(m.k[2]*n.k[2]/t.k)
            MH.temp[k,2]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            MH.temp[k,3]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/t.k^3
            MH.temp[k,4]<-b.k[2]-(n.k[2]*m.k[1]/t.k)
            MH.temp[k,5]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            
          } else {
            to.print<-T
          } } 
        
        if (to.print==T) {
          print (paste("Only binary response data are supported in the current version."))}
        #-----------------------------------------------------------------------------
        MH.values[j,1]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,2],na.rm=T)) 
        MH.values[j,2]<-pchisq(MH.values[j,1], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,3]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,3],na.rm=T))
        MH.values[j,4]<-pchisq(MH.values[j,3], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,5]<-(abs(sum(MH.temp[,4],na.rm=T)))^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,6]<-pchisq(MH.values[j,5], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,7]<-(abs(sum(MH.temp[,4],na.rm=T))-0.5)^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,8]<-pchisq( MH.values[j,7], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        #------------------------------------------------------------------------------
        #compute adjusted MH test statistic 
        data.k<-base::subset(data.use[,c(1:4,(4+which(item.select.idx==j)))])
        names(data.k)[5]<-"Item"
        
        colnames(strata.mat)<-names((c.tables.all[[which(item.select.idx==j)]]))
        strata.mat.validcol<-strata.mat[,names((c.tables.valid[[which(item.select.idx==j)]]))]
        
        strata.mat.valid<-strata.mat.validcol[!(rowSums(strata.mat.validcol)==0),]
        data.use.valid<-data.k[!(rowSums(strata.mat.validcol)==0),]
        
        Cluster.sizes.valid<-table(data.use.valid$Cluster)
        if (!sum(Cluster.sizes.valid==1)==0) {
          cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
          cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
        } else {
          cluster.id.to.remove<-NULL
        }
        
        data.use.j<-data.use.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        strata.mat.j<-strata.mat.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        
        table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
        table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        
        while (sum(rowSums(table.r)==0)>0 | sum(rowSums(table.c)==0)>0) {
          
          strata.mat.j<-strata.mat.j[!(rowSums(table.r)==0),]
          strata.mat.j<-strata.mat.j[!(rowSums(table.c)==0),]
          data.use.j<-data.use.j[!(rowSums(table.r)==0),]
          data.use.j<-data.use.j[!(rowSums(table.c)==0),]
          
          Cluster.sizes.valid<-table(data.use.j$Cluster)
          
          if (!sum(Cluster.sizes.valid==1)==0) {
            cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
            cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
          } else {
            cluster.id.to.remove<-NULL
          }
          
          data.use.j<-data.use.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          strata.mat.j<-strata.mat.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          
          table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
          table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        }
        
        Cluster.values.j<-as.numeric(levels(factor(data.use.j$Cluster)))
        Cluster.sizes.j<-table(factor(data.use.j$Cluster))
        Num.cluster.j<-length(Cluster.sizes.j)
        Max.cluste.size.j<-max(Cluster.sizes.j)
        Min.cluster.size.j<-min(Cluster.sizes.j)
        
        Stratum.values.j<-as.numeric(levels(factor(data.use.j$Stratum)))
        Stratum.sizes.j<-table(data.use.j$Stratum) 
        Num.Stratum.j<-length(Stratum.sizes.j)
        Max.Stratum.size.j<-max(Stratum.sizes.j)
        Min.Stratum.size.j<-min(Stratum.sizes.j)
        
        gamma.hat<-matrix(NA,dim(data.use.j)[1])
        
        for (i in 1:dim(data.use.j)[1]) { 
          for (k in Stratum.values.j) { 
            if (data.use.j$Stratum[i]==k) {
              gamma.hat[i]<-log((c.table.list[[which(Stratum.values.j==k)]][2,3])/(c.table.list[[which(Stratum.values.j==k)]][1,3]))}
          } 
        } 
        
        mu.hat<-(exp(gamma.hat))/(1+(exp(gamma.hat)))
        var.fun<-mu.hat*(1-mu.hat)
        
        var.A <-var.B<- matrix(0, (Num.Stratum.j+1),(Num.Stratum.j+1))
        
        for (c in Cluster.values.j) {
          
          data.c.Group<-data.use.j[which(data.use.j$Cluster==c),c(2)]
          data.c.strata.mat<-base::subset(strata.mat.j,data.use.j$Cluster==c)
          x.mat<-data.c<-as.matrix(cbind(data.c.Group,data.c.strata.mat))
          
          y.j.c<-data.use.j[which(data.use.j$Cluster==c),5]
          mu.hat.j.c<-mu.hat[which(data.use.j$Cluster==c)]
          cov.y.mat.c<-as.matrix((y.j.c-mu.hat.j.c)%*%t(y.j.c-mu.hat.j.c))
          
          var.fun.c<-var.fun[which(data.use.j$Cluster==c)] 
          
          ifelse(length(var.fun.c)==1, diag.var.fun.c<-var.fun.c,
                 diag.var.fun.c<-diag(var.fun.c))
          
          var.A<-var.A+t(x.mat)%*%diag.var.fun.c%*%x.mat 
          var.B<-var.B+t(x.mat)%*%cov.y.mat.c%*%x.mat
        }
        
        var.N<-1/(solve(var.A)[1,1])
        var.R<-((solve(var.A)%*%(var.B)%*%solve(var.A))[1,1])*var.N*var.N
        f.mh<-var.R/var.N 
        
        MH.values[j,9]<-MH.values[j,3]/(correct.factor*f.mh)
        MH.values[j,10]<-pchisq(MH.values[j,9], df=1, ncp = 0, lower.tail = F, log.p = F)
        MH.values[j,11]<-f.mh
        MH.values[j,12]<-correct.factor*f.mh
        ifelse (MH.values[j,10]<alpha,MH.values[j,13]<-1, MH.values[j,13]<-0)
        MH.values[j,14]<-nrow(data.use.j)
        MH.values[j,15]<-Num.Stratum.j
        MH.values[j,16]<-Num.cluster.j
      }
      
    } else if ((is.null(anchor.items)) & (purification==F)) {
      
      Responses.use<-data.use[names(Response.data)]
      Cluster.values<-as.numeric(levels(factor(data.use$Cluster)))
      Cluster.sizes<-table(data.use$Cluster)
      Num.cluster<-length(Cluster.sizes)
      Max.cluste.size<-max(Cluster.sizes)
      Min.cluster.size<-min(Cluster.sizes)
      
      Stratum.values<-as.numeric(levels(factor(data.use$Stratum)))
      Stratum.sizes<-table(data.use$Stratum) 
      Num.Stratum<-length(Stratum.sizes)
      Max.Stratum.size<-max(Stratum.sizes)
      Min.Stratum.size<-min(Stratum.sizes)
      
      
      strata.mat <- matrix(0, nrow=nrow(data.use), ncol=Num.Stratum)
      ifelse ((min(Stratum.values)==0), Strata.temp<-data.use$Stratum+1, Strata.temp<-data.use$Stratum)
      Stratum.temp<-plyr::mapvalues(data.use$Stratum, from=as.numeric(Stratum.values), 
                                    to=seq(1,Num.Stratum),warn_missing = TRUE)
      strata.mat[cbind(seq(Stratum.temp), Stratum.temp)] <- 1
      colnames(strata.mat)<-names(Stratum.sizes)
      
      #-------------------------------------------------------------
      MH.values<-matrix(NA,ncol(Responses.use),16)
      to.print<-F
      
      for (j in 1:ncol(Responses.use)) { 
        
        c.table.list<-c.tables.valid[[j]]
        MH.temp<-matrix(NA,length(c.table.list),5)
        
        for (k in 1:length(c.table.list)) {
          
          c.table.k<-c.table.list[[k]]
          
          n.k<-c.table.k[-nrow(c.table.k),ncol(c.table.k)]
          m.k<-c.table.k[nrow(c.table.k),-ncol(c.table.k)]
          t.k<-c.table.k[nrow(c.table.k),ncol(c.table.k)]
          
          a.k<-c.table.k[-nrow(c.table.k),2]
          b.k<-c.table.k[-nrow(c.table.k),1]
          
          if (length(a.k)==2) {
            MH.temp[k,1]<-a.k[2]-(m.k[2]*n.k[2]/t.k)
            MH.temp[k,2]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            MH.temp[k,3]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/t.k^3
            MH.temp[k,4]<-b.k[2]-(n.k[2]*m.k[1]/t.k)
            MH.temp[k,5]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            
          } else {
            to.print<-T
          } } 
        
        if (to.print==T) {
          print (paste("Only binary response data are supported in the current version."))}
        #-----------------------------------------------------------------------------
        MH.values[j,1]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,2],na.rm=T)) 
        MH.values[j,2]<-pchisq(MH.values[j,1], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,3]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,3],na.rm=T))
        MH.values[j,4]<-pchisq(MH.values[j,3], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,5]<-(abs(sum(MH.temp[,4],na.rm=T)))^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,6]<-pchisq(MH.values[j,5], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,7]<-(abs(sum(MH.temp[,4],na.rm=T))-0.5)^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,8]<-pchisq( MH.values[j,7], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        #------------------------------------------------------------------------------
        #compute adjusted MH test statistic 
        data.k<-base::subset(data.use[,c(1:4,4+j)])
        names(data.k)[5]<-"Item"
        
        colnames(strata.mat)<-names((c.tables.all[[j]]))
        strata.mat.validcol<-strata.mat[,names((c.tables.valid[[j]]))]
        
        strata.mat.valid<-strata.mat.validcol[!(rowSums(strata.mat.validcol)==0),]
        data.use.valid<-data.k[!(rowSums(strata.mat.validcol)==0),]
        
        Cluster.sizes.valid<-table(data.use.valid$Cluster)
        if (!sum(Cluster.sizes.valid==1)==0) {
          cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
          cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
        } else {
          cluster.id.to.remove<-NULL
        }
        
        data.use.j<-data.use.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        strata.mat.j<-strata.mat.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        
        table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
        table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        
        while (sum(rowSums(table.r)==0)>0 | sum(rowSums(table.c)==0)>0) {
          
          strata.mat.j<-strata.mat.j[!(rowSums(table.r)==0),]
          strata.mat.j<-strata.mat.j[!(rowSums(table.c)==0),]
          data.use.j<-data.use.j[!(rowSums(table.r)==0),]
          data.use.j<-data.use.j[!(rowSums(table.c)==0),]
          
          Cluster.sizes.valid<-table(data.use.j$Cluster)
          
          if (!sum(Cluster.sizes.valid==1)==0) {
            cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
            cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
          } else {
            cluster.id.to.remove<-NULL
          }
          
          data.use.j<-data.use.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          strata.mat.j<-strata.mat.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          
          table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
          table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        }
        
        Cluster.values.j<-as.numeric(levels(factor(data.use.j$Cluster)))
        Cluster.sizes.j<-table(factor(data.use.j$Cluster))
        Num.cluster.j<-length(Cluster.sizes.j)
        Max.cluste.size.j<-max(Cluster.sizes.j)
        Min.cluster.size.j<-min(Cluster.sizes.j)
        
        Stratum.values.j<-as.numeric(levels(factor(data.use.j$Stratum)))
        Stratum.sizes.j<-table(data.use.j$Stratum) 
        Num.Stratum.j<-length(Stratum.sizes.j)
        Max.Stratum.size.j<-max(Stratum.sizes.j)
        Min.Stratum.size.j<-min(Stratum.sizes.j)
        
        gamma.hat<-matrix(NA,dim(data.use.j)[1])
        
        for (i in 1:dim(data.use.j)[1]) { 
          for (k in Stratum.values.j) { 
            if (data.use.j$Stratum[i]==k) {
              gamma.hat[i]<-log((c.table.list[[which(Stratum.values.j==k)]][2,3])/(c.table.list[[which(Stratum.values.j==k)]][1,3]))}
          } 
        } 
        
        mu.hat<-(exp(gamma.hat))/(1+(exp(gamma.hat)))
        var.fun<-mu.hat*(1-mu.hat)
        
        var.A <-var.B<- matrix(0, (Num.Stratum.j+1),(Num.Stratum.j+1))
        
        for (c in Cluster.values.j) {
          
          data.c.Group<-data.use.j[which(data.use.j$Cluster==c),c(2)]
          data.c.strata.mat<-base::subset(strata.mat.j,data.use.j$Cluster==c)
          x.mat<-data.c<-as.matrix(cbind(data.c.Group,data.c.strata.mat))
          
          y.j.c<-data.use.j[which(data.use.j$Cluster==c),5]
          mu.hat.j.c<-mu.hat[which(data.use.j$Cluster==c)]
          cov.y.mat.c<-as.matrix((y.j.c-mu.hat.j.c)%*%t(y.j.c-mu.hat.j.c))
          
          var.fun.c<-var.fun[which(data.use.j$Cluster==c)] 
          
          ifelse(length(var.fun.c)==1, diag.var.fun.c<-var.fun.c,
                 diag.var.fun.c<-diag(var.fun.c))
          
          var.A<-var.A+t(x.mat)%*%diag.var.fun.c%*%x.mat 
          var.B<-var.B+t(x.mat)%*%cov.y.mat.c%*%x.mat
        }
        
        var.N<-1/(solve(var.A)[1,1])
        var.R<-((solve(var.A)%*%(var.B)%*%solve(var.A))[1,1])*var.N*var.N
        f.mh<-var.R/var.N 
        
        MH.values[j,9]<-MH.values[j,3]/(correct.factor*f.mh)
        MH.values[j,10]<-pchisq(MH.values[j,9], df=1, ncp = 0, lower.tail = F, log.p = F)
        MH.values[j,11]<-f.mh
        MH.values[j,12]<-correct.factor*f.mh
        ifelse (MH.values[j,10]<alpha,MH.values[j,13]<-1, MH.values[j,13]<-0)
        MH.values[j,14]<-nrow(data.use.j)
        MH.values[j,15]<-Num.Stratum.j
        MH.values[j,16]<-Num.cluster.j
      }
      
      
    } else if ((is.null(anchor.items)) & (purification==T)) {
      
      if (!is.null(Stratum)) {
        print (paste("Purification will be applied using observed total score as stratum."))}
      
      Responses.use<-data.use[names(Response.data)]
      Cluster.values<-as.numeric(levels(factor(data.use$Cluster)))
      Cluster.sizes<-table(data.use$Cluster)
      Num.cluster<-length(Cluster.sizes)
      Max.cluste.size<-max(Cluster.sizes)
      Min.cluster.size<-min(Cluster.sizes)
      
      Stratum.values<-as.numeric(levels(factor(data.use$Stratum)))
      Stratum.sizes<-table(data.use$Stratum) 
      Num.Stratum<-length(Stratum.sizes)
      Max.Stratum.size<-max(Stratum.sizes)
      Min.Stratum.size<-min(Stratum.sizes)
      
      strata.mat <- matrix(0, nrow=nrow(data.use), ncol=Num.Stratum)
      ifelse ((min(Stratum.values)==0), Strata.temp<-data.use$Stratum+1, Strata.temp<-data.use$Stratum)
      
      Stratum.temp<-plyr::mapvalues(data.use$Stratum, from=as.numeric(Stratum.values), 
                                    to=seq(1,Num.Stratum),warn_missing = TRUE)
      strata.mat[cbind(seq(Stratum.temp), Stratum.temp)] <- 1
      colnames(strata.mat)<-names(Stratum.sizes)
      
      #-------------------------------------------------------------
      MH.values<-matrix(NA,ncol(Responses.use),16)
      to.print<-F
      
      for (j in 1:ncol(Responses.use)) {
        
        c.table.list<-c.tables.valid[[j]]
        MH.temp<-matrix(NA,length(c.table.list),5)
        
        for (k in 1:length(c.table.list)) { 
          
          c.table.k<-c.table.list[[k]]
          
          n.k<-c.table.k[-nrow(c.table.k),ncol(c.table.k)]
          m.k<-c.table.k[nrow(c.table.k),-ncol(c.table.k)]
          t.k<-c.table.k[nrow(c.table.k),ncol(c.table.k)]
          
          a.k<-c.table.k[-nrow(c.table.k),2]
          b.k<-c.table.k[-nrow(c.table.k),1]
          
          if (length(a.k)==2) {
            MH.temp[k,1]<-a.k[2]-(m.k[2]*n.k[2]/t.k)
            MH.temp[k,2]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            MH.temp[k,3]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/t.k^3
            MH.temp[k,4]<-b.k[2]-(n.k[2]*m.k[1]/t.k)
            MH.temp[k,5]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
            
          } else {
            to.print<-T
          } } 
        
        if (to.print==T) {
          print (paste("Only binary response data are supported in the current version."))}
        
        MH.values[j,1]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,2],na.rm=T))
        MH.values[j,2]<-pchisq(MH.values[j,1], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,3]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,3],na.rm=T))
        MH.values[j,4]<-pchisq(MH.values[j,3], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,5]<-(abs(sum(MH.temp[,4],na.rm=T)))^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,6]<-pchisq(MH.values[j,5], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        MH.values[j,7]<-(abs(sum(MH.temp[,4],na.rm=T))-0.5)^2/sum(MH.temp[,5],na.rm=T)
        MH.values[j,8]<-pchisq( MH.values[j,7], df=1, ncp = 0, lower.tail = F, log.p = F)
        
        #------------------------------------------------------------------------------
        data.k<-base::subset(data.use[,c(1:4,4+j)])
        names(data.k)[5]<-"Item"
        
        colnames(strata.mat)<-names((c.tables.all[[j]]))
        strata.mat.validcol<-strata.mat[,names((c.tables.valid[[j]]))]
        
        strata.mat.valid<-strata.mat.validcol[!(rowSums(strata.mat.validcol)==0),]
        data.use.valid<-data.k[!(rowSums(strata.mat.validcol)==0),]
        
        Cluster.sizes.valid<-table(data.use.valid$Cluster)
        if (!sum(Cluster.sizes.valid==1)==0) {
          cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
          cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
        } else {
          cluster.id.to.remove<-NULL
        }
        
        data.use.j<-data.use.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        strata.mat.j<-strata.mat.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
        
        table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
        table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        
        while (sum(rowSums(table.r)==0)>0 | sum(rowSums(table.c)==0)>0) {
          
          strata.mat.j<-strata.mat.j[!(rowSums(table.r)==0),]
          strata.mat.j<-strata.mat.j[!(rowSums(table.c)==0),]
          data.use.j<-data.use.j[!(rowSums(table.r)==0),]
          data.use.j<-data.use.j[!(rowSums(table.c)==0),]    
          Cluster.sizes.valid<-table(data.use.j$Cluster)
          
          if (!sum(Cluster.sizes.valid==1)==0) {
            cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
            cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
          } else {
            cluster.id.to.remove<-NULL
          }
          
          data.use.j<-data.use.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          strata.mat.j<-strata.mat.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
          
          table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
          table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
        }
        
        Cluster.values.j<-as.numeric(levels(factor(data.use.j$Cluster)))
        Cluster.sizes.j<-table(factor(data.use.j$Cluster))
        Num.cluster.j<-length(Cluster.sizes.j)
        Max.cluste.size.j<-max(Cluster.sizes.j)
        Min.cluster.size.j<-min(Cluster.sizes.j)
        
        Stratum.values.j<-as.numeric(levels(factor(data.use.j$Stratum)))
        Stratum.sizes.j<-table(data.use.j$Stratum) 
        Num.Stratum.j<-length(Stratum.sizes.j)
        Max.Stratum.size.j<-max(Stratum.sizes.j)
        Min.Stratum.size.j<-min(Stratum.sizes.j)
        
        gamma.hat<-matrix(NA,dim(data.use.j)[1])
        
        for (i in 1:dim(data.use.j)[1]) { 
          for (k in Stratum.values.j) { 
            if (data.use.j$Stratum[i]==k) {
              gamma.hat[i]<-log((c.table.list[[which(Stratum.values.j==k)]][2,3])/(c.table.list[[which(Stratum.values.j==k)]][1,3]))}
          } 
        } 
        
        mu.hat<-(exp(gamma.hat))/(1+(exp(gamma.hat)))
        var.fun<-mu.hat*(1-mu.hat)
        
        var.A <-var.B<- matrix(0, (Num.Stratum.j+1),(Num.Stratum.j+1))
        
        for (c in Cluster.values.j) {
          
          data.c.Group<-data.use.j[which(data.use.j$Cluster==c),c(2)]
          data.c.strata.mat<-base::subset(strata.mat.j,data.use.j$Cluster==c)
          x.mat<-data.c<-as.matrix(cbind(data.c.Group,data.c.strata.mat))
          
          y.j.c<-data.use.j[which(data.use.j$Cluster==c),5]
          mu.hat.j.c<-mu.hat[which(data.use.j$Cluster==c)]
          cov.y.mat.c<-as.matrix((y.j.c-mu.hat.j.c)%*%t(y.j.c-mu.hat.j.c))
          
          var.fun.c<-var.fun[which(data.use.j$Cluster==c)] 
          
          ifelse(length(var.fun.c)==1, diag.var.fun.c<-var.fun.c,
                 diag.var.fun.c<-diag(var.fun.c))
          
          var.A<-var.A+t(x.mat)%*%diag.var.fun.c%*%x.mat 
          var.B<-var.B+t(x.mat)%*%cov.y.mat.c%*%x.mat
        }
        
        var.N<-1/(solve(var.A)[1,1])
        var.R<-((solve(var.A)%*%(var.B)%*%solve(var.A))[1,1])*var.N*var.N
        f.mh<-var.R/var.N 
        
        MH.values[j,9]<-MH.values[j,3]/(correct.factor*f.mh)
        MH.values[j,10]<-pchisq(MH.values[j,9], df=1, ncp = 0, lower.tail = F, log.p = F)
        MH.values[j,11]<-f.mh
        MH.values[j,12]<-correct.factor*f.mh
        ifelse (MH.values[j,10]<alpha,MH.values[j,13]<-1, MH.values[j,13]<-0)
        MH.values[j,14]<-nrow(data.use.j)
        MH.values[j,15]<-Num.Stratum.j
        MH.values[j,16]<-Num.cluster.j
      } 
      
      DIF.idx<-MH.values[,13]
      
      if (sum(DIF.idx)==0) {
        print (paste ('No DIF items detected. No Purification applied.'))
      }
      
      iter<-1
      stop.purify<-F
      
      while ((sum(DIF.idx)>0) & (iter<max.iter+1) & (stop.purify==F)) {
        
        print(paste ("Purification iteration ", iter, sep=''))
        item.names.to.use<-names(Response.data)[DIF.idx==0]
        Response.data.2<-Response.data[item.names.to.use]
        new.stratum<-rowSums(Response.data.2,na.rm=T)
        
        c.table.out<-ContigencyTables(Response.data, Response.code, Group, group.names, 
                                      Stratum=new.stratum, Cluster, missing.code, missing.impute, 
                                      print.information=F)
        c.tables.all<-c.table.out$c.table.list.all
        c.tables.valid<-c.table.out$c.table.list.valid
        Stratum.statistics<-c.table.out$Strata.stats
        data.use<-c.table.out$data.out
        
        Group.use<-data.use[,1]
        Group.factor.use<-data.use[,2]
        Cluster.use<-data.use[,3]
        Stratum<-data.use[,4]
        
        Responses.use<-data.use[names(Response.data)]
        Cluster.values<-as.numeric(levels(factor(data.use$Cluster)))
        Cluster.sizes<-table(data.use$Cluster)
        Num.cluster<-length(Cluster.sizes)
        Max.cluste.size<-max(Cluster.sizes)
        Min.cluster.size<-min(Cluster.sizes)
        
        Stratum.values<-as.numeric(levels(factor(data.use$Stratum)))
        Stratum.sizes<-table(data.use$Stratum) 
        Num.Stratum<-length(Stratum.sizes)
        Max.Stratum.size<-max(Stratum.sizes)
        Min.Stratum.size<-min(Stratum.sizes)
        
        strata.mat <- matrix(0, nrow=nrow(data.use), ncol=Num.Stratum)
        ifelse ((min(Stratum.values)==0), Strata.temp<-data.use$Stratum+1, Strata.temp<-data.use$Stratum)
        
        Stratum.temp<-plyr::mapvalues(data.use$Stratum, from=as.numeric(Stratum.values), 
                                      to=seq(1,Num.Stratum),warn_missing = TRUE)
        strata.mat[cbind(seq(Stratum.temp), Stratum.temp)] <- 1
        colnames(strata.mat)<-names(Stratum.sizes)
        
        MH.values<-matrix(NA,ncol(Responses.use),16)
        to.print<-F
        
        for (j in 1:ncol(Responses.use)) {
          
          c.table.list<-c.tables.valid[[j]]
          MH.temp<-matrix(NA,length(c.table.list),5)
          
          for (k in 1:length(c.table.list)) { 
            
            c.table.k<-c.table.list[[k]]
            
            n.k<-c.table.k[-nrow(c.table.k),ncol(c.table.k)]
            m.k<-c.table.k[nrow(c.table.k),-ncol(c.table.k)]
            t.k<-c.table.k[nrow(c.table.k),ncol(c.table.k)]
            
            a.k<-c.table.k[-nrow(c.table.k),2]
            b.k<-c.table.k[-nrow(c.table.k),1]
            
            if (length(a.k)==2) {
              MH.temp[k,1]<-a.k[2]-(m.k[2]*n.k[2]/t.k)
              MH.temp[k,2]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
              MH.temp[k,3]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/t.k^3
              MH.temp[k,4]<-b.k[2]-(n.k[2]*m.k[1]/t.k)
              MH.temp[k,5]<-(m.k[1]*m.k[2]*n.k[1]*n.k[2])/(t.k^2*(t.k-1))
              
            } else {
              to.print<-T
            } } 
          
          if (to.print==T) {
            print (paste("Only binary response data are supported in the current version."))}
          #-----------------------------------------------------------------------------
          MH.values[j,1]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,2],na.rm=T))
          MH.values[j,2]<-pchisq(MH.values[j,1], df=1, ncp = 0, lower.tail = F, log.p = F)
          
          MH.values[j,3]<-sum(MH.temp[,1],na.rm=T)^2/(sum(MH.temp[,3],na.rm=T))
          MH.values[j,4]<-pchisq(MH.values[j,3], df=1, ncp = 0, lower.tail = F, log.p = F)
          
          MH.values[j,5]<-(abs(sum(MH.temp[,4],na.rm=T)))^2/sum(MH.temp[,5],na.rm=T)
          MH.values[j,6]<-pchisq(MH.values[j,5], df=1, ncp = 0, lower.tail = F, log.p = F)
          
          MH.values[j,7]<-(abs(sum(MH.temp[,4],na.rm=T))-0.5)^2/sum(MH.temp[,5],na.rm=T)
          MH.values[j,8]<-pchisq( MH.values[j,7], df=1, ncp = 0, lower.tail = F, log.p = F)
          
          #------------------------------------------------------------------------------
          #compute adjusted MH test statistic 
          data.k<-base::subset(data.use[,c(1:4,4+j)])
          names(data.k)[5]<-"Item"
          
          colnames(strata.mat)<-names((c.tables.all[[j]]))
          strata.mat.validcol<-strata.mat[,names((c.tables.valid[[j]]))]
          
          strata.mat.valid<-strata.mat.validcol[!(rowSums(strata.mat.validcol)==0),]
          data.use.valid<-data.k[!(rowSums(strata.mat.validcol)==0),]
          
          Cluster.sizes.valid<-table(data.use.valid$Cluster)
          if (!sum(Cluster.sizes.valid==1)==0) {
            cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
            cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
          } else {
            cluster.id.to.remove<-NULL
          }
          
          data.use.j<-data.use.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
          strata.mat.j<-strata.mat.valid[which(!(data.use.valid$Cluster %in% cluster.id.to.remove)),]
          
          table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
          table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
          
          while (sum(rowSums(table.r)==0)>0 | sum(rowSums(table.c)==0)>0) {
            
            strata.mat.j<-strata.mat.j[!(rowSums(table.r)==0),]
            strata.mat.j<-strata.mat.j[!(rowSums(table.c)==0),]
            data.use.j<-data.use.j[!(rowSums(table.r)==0),]
            data.use.j<-data.use.j[!(rowSums(table.c)==0),]      
            Cluster.sizes.valid<-table(data.use.j$Cluster)
            
            if (!sum(Cluster.sizes.valid==1)==0) {
              cluster.to.remove<-Cluster.sizes.valid[!(Cluster.sizes.valid>1)]
              cluster.id.to.remove<-as.numeric(names(cluster.to.remove))
            } else {
              cluster.id.to.remove<-NULL
            }
            
            data.use.j<-data.use.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
            strata.mat.j<-strata.mat.j[which(!(data.use.j$Cluster %in% cluster.id.to.remove)),]
            
            table.r<-ftable(table(data.use.j$Stratum,data.use.j$Item,data.use.j$Group.factor))
            table.c<- ftable(table(data.use.j$Stratum,data.use.j$Group.factor,data.use.j$Item))
          }
          
          Cluster.values.j<-as.numeric(levels(factor(data.use.j$Cluster)))
          Cluster.sizes.j<-table(factor(data.use.j$Cluster))
          Num.cluster.j<-length(Cluster.sizes.j)
          Max.cluste.size.j<-max(Cluster.sizes.j)
          Min.cluster.size.j<-min(Cluster.sizes.j)
          
          Stratum.values.j<-as.numeric(levels(factor(data.use.j$Stratum)))
          Stratum.sizes.j<-table(data.use.j$Stratum) 
          Num.Stratum.j<-length(Stratum.sizes.j)
          Max.Stratum.size.j<-max(Stratum.sizes.j)
          Min.Stratum.size.j<-min(Stratum.sizes.j)
          
          gamma.hat<-matrix(NA,dim(data.use.j)[1])
          
          for (i in 1:dim(data.use.j)[1]) { 
            for (k in Stratum.values.j) { 
              if (data.use.j$Stratum[i]==k) {
                gamma.hat[i]<-log((c.table.list[[which(Stratum.values.j==k)]][2,3])/(c.table.list[[which(Stratum.values.j==k)]][1,3]))}
            } 
          } 
          
          mu.hat<-(exp(gamma.hat))/(1+(exp(gamma.hat)))
          var.fun<-mu.hat*(1-mu.hat)
          
          var.A <-var.B<- matrix(0, (Num.Stratum.j+1),(Num.Stratum.j+1))
          
          for (c in Cluster.values.j) {
            
            data.c.Group<-data.use.j[which(data.use.j$Cluster==c),c(2)]
            data.c.strata.mat<-base::subset(strata.mat.j,data.use.j$Cluster==c)
            x.mat<-data.c<-as.matrix(cbind(data.c.Group,data.c.strata.mat))
            
            y.j.c<-data.use.j[which(data.use.j$Cluster==c),5]
            mu.hat.j.c<-mu.hat[which(data.use.j$Cluster==c)]
            cov.y.mat.c<-as.matrix((y.j.c-mu.hat.j.c)%*%t(y.j.c-mu.hat.j.c))
            
            var.fun.c<-var.fun[which(data.use.j$Cluster==c)] 
            
            ifelse(length(var.fun.c)==1, diag.var.fun.c<-var.fun.c,
                   diag.var.fun.c<-diag(var.fun.c))
            
            var.A<-var.A+t(x.mat)%*%diag.var.fun.c%*%x.mat 
            var.B<-var.B+t(x.mat)%*%cov.y.mat.c%*%x.mat
          }
          
          var.N<-1/(solve(var.A)[1,1])
          var.R<-((solve(var.A)%*%(var.B)%*%solve(var.A))[1,1])*var.N*var.N
          f.mh<-var.R/var.N 
          
          MH.values[j,9]<-MH.values[j,3]/(correct.factor*f.mh)
          MH.values[j,10]<-pchisq(MH.values[j,9], df=1, ncp = 0, lower.tail = F, log.p = F)
          MH.values[j,11]<-f.mh
          MH.values[j,12]<-correct.factor*f.mh
          ifelse (MH.values[j,10]<alpha,MH.values[j,13]<-1, MH.values[j,13]<-0)
          MH.values[j,14]<-nrow(data.use.j)
          MH.values[j,15]<-Num.Stratum.j
          MH.values[j,16]<-Num.cluster.j
        } 
        DIF.idx.new<-MH.values[,13]
        
        if (sum(DIF.idx==DIF.idx.new)==length(DIF.idx)) {
          stop.purify<-T
        } else {
          DIF.idx<-DIF.idx.new
          iter<-iter+1
        }}
    }
    if (!is.null (MH.values)) {
      MH.values<-cbind(round(MH.values[,1:12],4),MH.values[,13:16])
      
      colnames(MH.values)<-c("MH.unadj","p.value","MH.score","p.value",
                             "MH.GMH","p.value","MH.Yates","p.value",
                             "MH.adj","p.value","f.adj",'f.adj.correct',
                             'DIF.Item (Yes)',
                             "N.Valid","N.Strata","N.Cluster")
      rownames(MH.values)<-colnames(Response.data)
      
      MH.values<-MH.values[rowSums(is.na(MH.values)) != ncol(MH.values), ]}
  } else {
    print (paste("Only binary response data are supported in the current version."))
    
    if (is.null(anchor.items)) {
      c.table.out<-ContigencyTables(Response.data, Response.code, Group, group.names, 
                                    Stratum, Cluster, missing.code, missing.impute,
                                    print.information = FALSE)
      c.tables.all<-c.table.out$c.table.list.all
      c.tables.valid<-c.table.out$c.table.list.valid
      Stratum.statistics<-c.table.out$Strata.stats
      data.use<-c.table.out$data.out} else {
        anchor.names<-names(anchor.items)
        item.use.names<-names(Response.data) %in% anchor.names
        Response.data.1<-Response.data[!item.use.names]
        c.table.out<-ContigencyTables(Response.data.1, Response.code, Group, group.names, 
                                      Stratum, Cluster, missing.code, missing.impute,
                                      print.information = FALSE)
        c.tables.all<-c.table.out$c.table.list.all
        c.tables.valid<-c.table.out$c.table.list.valid
        Stratum.statistics<-c.table.out$Strata.stats
        data.use<-c.table.out$data.out
      }
    
    MH.values<-NULL
  }
  
  return( list(MH.values=MH.values,
               Stratum.statistics=Stratum.statistics,
               c.tables.all=c.tables.all, 
               c.tables.valid=c.tables.valid,
               data.out=c.table.out$data.out)) }

