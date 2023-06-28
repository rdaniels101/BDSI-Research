set.seed(7)
# load the library
library(caret)
# load the data
# define the control using a random forest selection function
control <- rfeControl(functions=rfFuncs, method="cv", number=10)
# run the RFE algorithm
results <- rfe(pathway.scores, Y, sizes=c(1:30), rfeControl=control)
# summarize the results
print(results)
# list the chosen features
predictors(results)
# plot the results
plot(results, type=c("g", "o"),xlim=c(0,30))

features_pathway <- results[["optVariables"]][1:10]

control <- rfeControl(functions=rfFuncs, method="cv", number=10)
# run the RFE algorithm
results_pc <- rfe(pc_scores, Y, sizes=c(1:30), rfeControl=control)
# summarize the results
print(results_pc)
# list the chosen features
predictors(results_pc)
# plot the results
plot(results_pc, type=c("g", "o"),xlim=c(0,30))

features_pc <- results[["optVariables"]][1:4]

pc_surv2=pc_surv %>% 
  select(FLAIR_NCR.NET.17, T2_NCR.NET.4, T2_ED.1, FLAIR_NCR.NET.5,Y)

intercept_only <- lm(g(Y) ~ 1, data=pc_surv2)

#define model with all predictors
all <- lm(g(Y) ~ ., data=pc_surv2)

#perform forward stepwise regression
forward_pc <- step(intercept_only, direction='forward', scope=formula(all), trace=0)

#perform backward stepwise regression
backward_pc <- step(intercept_only, direction='backward', scope=formula(all), trace=0)

control <- rfeControl(functions=rfFuncs, method="cv", number=10)
# run the RFE algorithm
results_pc <- rfe(pc_scores, Y, sizes=c(1:30), rfeControl=control)
# summarize the results
print(results_pc)
# list the chosen features
predictors(results_pc)
# plot the results
plot(results_pc, type=c("g", "o"),xlim=c(0,30))

pathway_surv=as.data.frame(cbind(pathway.scores,Y))

pathway_surv1=pathway_surv %>% 
  select(KEGG_RIG_I_LIKE_RECEPTOR_SIGNALING_PATHWAY,MODULE_457
         ,MORF_RAD21,KEGG_RIBOFLAVIN_METABOLISM
         ,GNF2_TTN,MORF_SART1
         ,MYC_UP.V1_DN,MORF_TERF1
         ,MODULE_440,MODULE_159,Y)
intercept_pathway <- lm(g(Y) ~ 1, data=pathway_surv1)

#define model with all predictors
all_pathway <- lm(g(Y) ~ ., data=pathway_surv1)

#perform forward stepwise regression
forward_pathway <- step(intercept_pathway, direction='forward', 
                        scope=formula(all_pathway), trace=0)

#perform backward stepwise regression
backward_pathway <- step(intercept_pathway, direction='backward', 
                         scope=formula(all_pathway), trace=0)

names_pathway <- colnames(pathway.scores)
combos <- unique(gsub("\\_.*$", "", names_pathway))
combos <- unique(gsub("\\..*$", "", combos))

possi_feat_pathway=sapply(combos, function(combo) which(grepl(combo, names_pathway)))
features_pathway1=c()

for (i in 1:length(possi_feat_pathway)) {
  if(length(possi_feat_pathway[[i]])>2)
  {
    features_pathway1=c(features_pathway1,sample(possi_feat_pathway[[i]],1)) 
  }
}

pathway_surv1=as.data.frame(cbind(pathway.scores[,features_pathway1],Y))