Thank you for reporting this.

What you propose, that is:
> I assume that the most adequate error should be a NotFittedError asking to fit the estimator.

seems like the best solution to me.
yep, adding a `check_is_fitted(self)` at the beginning of each `get_feature_names_out` seems reasonable to me.
I agree with raising a `NotFittedError` if the estimator is not fitted.
@glemaitre , I would like to help solve this issue. Any tips you would like to share before I start ? 
The best would be to create a common test running for all estimators having `get_feature_names_out`. It will help to identify which part of the code to change.
I am going to work on this. I will share updates if any. 
Hi @JohnPCode, I would like to work on this issue. Are you still working on it ? Can I start working on it ? Let me know.
@glemaitre , I have tried to run tests on all estimators with ```get_feature_names_out```. However, it seems the code may have been changed while I was away. Could someone else have worked on the issue already?
I don't think so. Otherwise, a pull request would be associated with this issue.
@glemaitre Do you actually expect some kind of pytest test to be implemented ?
> Do you actually expect some kind of pytest test to be implemented ?

Yes I expect to have a common test where we make sure to raise a `NotFittedError` and make the necessary changes in the estimators.
@AlexBuzenet, I created a common test and ran it on all estimators with ```get feature names out```. Please take a look at the details below.  You can see the estimators which raise a ```NotFittedError``` and those that raise other types of Errors. 
<details>
<pre>(sklearn-dev) <font color="#26A269"><b>john@SwiftyXSwaggy</b></font>:<font color="#12488B"><b>~/Documents/Local_Code/scikit-learn</b></font>$ pytest -vsl sklearn/tests/test_common.py -k error_check_get_feature_names_out
<b>============================================================================ test session starts ============================================================================</b>
platform linux -- Python 3.9.15, pytest-7.2.0, pluggy-1.0.0 -- /home/john/miniconda3/envs/sklearn-dev/bin/python3.9
cachedir: .pytest_cache
rootdir: /home/john/Documents/Local_Code/scikit-learn, configfile: setup.cfg
plugins: cov-4.0.0, xdist-3.1.0
<b>collected 9597 items / 9400 deselected / 197 selected                                                                                                                       </b>

sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ARDRegression()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[AdaBoostClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[AdaBoostRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[AdditiveChi2Sampler()] (&apos;AdditiveChi2Sampler&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[AffinityPropagation()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[AgglomerativeClustering()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BaggingClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BaggingRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BayesianGaussianMixture()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BayesianRidge()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BernoulliNB()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BernoulliRBM()] (&apos;BernoulliRBM&apos;, NotFittedError(&quot;This BernoulliRBM instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Binarizer()] (&apos;Binarizer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Birch()] (&apos;Birch&apos;, NotFittedError(&quot;This Birch instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[BisectingKMeans()] (&apos;BisectingKMeans&apos;, NotFittedError(&quot;This BisectingKMeans instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[CCA()] (&apos;CCA&apos;, NotFittedError(&quot;This CCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[CalibratedClassifierCV(estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[CategoricalNB()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ClassifierChain(base_estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ComplementNB()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[CountVectorizer()] (&apos;CountVectorizer&apos;, NotFittedError(&apos;Vocabulary not fitted or provided&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DBSCAN()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DecisionTreeClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DecisionTreeRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DictVectorizer()] (&apos;DictVectorizer&apos;, AttributeError(&quot;&apos;DictVectorizer&apos; object has no attribute &apos;feature_names_&apos;&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DictionaryLearning()] (&apos;DictionaryLearning&apos;, NotFittedError(&quot;This DictionaryLearning instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DummyClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[DummyRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ElasticNet()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ElasticNetCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[EllipticEnvelope()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[EmpiricalCovariance()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ExtraTreeClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ExtraTreeRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ExtraTreesClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ExtraTreesRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[FactorAnalysis()] (&apos;FactorAnalysis&apos;, NotFittedError(&quot;This FactorAnalysis instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[FastICA()] (&apos;FastICA&apos;, NotFittedError(&quot;This FastICA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[FeatureAgglomeration()] (&apos;FeatureAgglomeration&apos;, NotFittedError(&quot;This FeatureAgglomeration instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[FeatureHasher()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[FunctionTransformer()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GammaRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GaussianMixture()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GaussianNB()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GaussianProcessClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GaussianProcessRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GaussianRandomProjection()] (&apos;GaussianRandomProjection&apos;, TypeError(&quot;&apos;str&apos; object cannot be interpreted as an integer&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GenericUnivariateSelect()] (&apos;GenericUnivariateSelect&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GradientBoostingClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GradientBoostingRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GraphicalLasso()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[GraphicalLassoCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[HashingVectorizer()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[HistGradientBoostingClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[HistGradientBoostingRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[HuberRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[IncrementalPCA()] (&apos;IncrementalPCA&apos;, NotFittedError(&quot;This IncrementalPCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[IsolationForest()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Isomap()] (&apos;Isomap&apos;, NotFittedError(&quot;This Isomap instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[IsotonicRegression()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[IterativeImputer()] (&apos;IterativeImputer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KBinsDiscretizer()] (&apos;KBinsDiscretizer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KMeans()] (&apos;KMeans&apos;, NotFittedError(&quot;This KMeans instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KNNImputer()] (&apos;KNNImputer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KNeighborsClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KNeighborsRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KNeighborsTransformer()] (&apos;KNeighborsTransformer&apos;, NotFittedError(&quot;This KNeighborsTransformer instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KernelCenterer()] (&apos;KernelCenterer&apos;, NotFittedError(&quot;This KernelCenterer instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KernelDensity()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KernelPCA()] (&apos;KernelPCA&apos;, NotFittedError(&quot;This KernelPCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[KernelRidge()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LabelBinarizer()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LabelEncoder()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LabelPropagation()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LabelSpreading()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Lars()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LarsCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Lasso()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LassoCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LassoLars()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LassoLarsCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LassoLarsIC()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LatentDirichletAllocation()] (&apos;LatentDirichletAllocation&apos;, NotFittedError(&quot;This LatentDirichletAllocation instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LedoitWolf()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LinearDiscriminantAnalysis()] (&apos;LinearDiscriminantAnalysis&apos;, NotFittedError(&quot;This LinearDiscriminantAnalysis instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LinearRegression()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LinearSVC()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LinearSVR()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LocalOutlierFactor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LocallyLinearEmbedding()] (&apos;LocallyLinearEmbedding&apos;, NotFittedError(&quot;This LocallyLinearEmbedding instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LogisticRegression()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[LogisticRegressionCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MDS()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MLPClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MLPRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MaxAbsScaler()] (&apos;MaxAbsScaler&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MeanShift()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MinCovDet()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MinMaxScaler()] (&apos;MinMaxScaler&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MiniBatchDictionaryLearning()] (&apos;MiniBatchDictionaryLearning&apos;, NotFittedError(&quot;This MiniBatchDictionaryLearning instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MiniBatchKMeans()] (&apos;MiniBatchKMeans&apos;, NotFittedError(&quot;This MiniBatchKMeans instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MiniBatchNMF()] (&apos;MiniBatchNMF&apos;, NotFittedError(&quot;This MiniBatchNMF instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MiniBatchSparsePCA()] (&apos;MiniBatchSparsePCA&apos;, NotFittedError(&quot;This MiniBatchSparsePCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MissingIndicator()] (&apos;MissingIndicator&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiLabelBinarizer()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiOutputClassifier(estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiOutputRegressor(estimator=Ridge())] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiTaskElasticNet()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiTaskElasticNetCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiTaskLasso()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultiTaskLassoCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[MultinomialNB()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NMF()] (&apos;NMF&apos;, NotFittedError(&quot;This NMF instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NearestCentroid()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NearestNeighbors()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NeighborhoodComponentsAnalysis()] (&apos;NeighborhoodComponentsAnalysis&apos;, NotFittedError(&quot;This NeighborhoodComponentsAnalysis instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Normalizer()] (&apos;Normalizer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NuSVC()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[NuSVR()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Nystroem()] (&apos;Nystroem&apos;, NotFittedError(&quot;This Nystroem instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OAS()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OPTICS()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OneClassSVM()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OneHotEncoder()] (&apos;OneHotEncoder&apos;, NotFittedError(&quot;This OneHotEncoder instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OneVsOneClassifier(estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OneVsRestClassifier(estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OrdinalEncoder()] (&apos;OrdinalEncoder&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OrthogonalMatchingPursuit()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OrthogonalMatchingPursuitCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[OutputCodeClassifier(estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PCA()] (&apos;PCA&apos;, NotFittedError(&quot;This PCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PLSCanonical()] (&apos;PLSCanonical&apos;, NotFittedError(&quot;This PLSCanonical instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PLSRegression()] (&apos;PLSRegression&apos;, NotFittedError(&quot;This PLSRegression instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PLSSVD()] (&apos;PLSSVD&apos;, NotFittedError(&quot;This PLSSVD instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PassiveAggressiveClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PassiveAggressiveRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PatchExtractor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Perceptron()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PoissonRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PolynomialCountSketch()] (&apos;PolynomialCountSketch&apos;, NotFittedError(&quot;This PolynomialCountSketch instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PolynomialFeatures()] (&apos;PolynomialFeatures&apos;, NotFittedError(&quot;This PolynomialFeatures instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[PowerTransformer()] (&apos;PowerTransformer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[QuadraticDiscriminantAnalysis()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[QuantileRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[QuantileTransformer()] (&apos;QuantileTransformer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RANSACRegressor(estimator=LinearRegression())] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RBFSampler()] (&apos;RBFSampler&apos;, NotFittedError(&quot;This RBFSampler instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RFE(estimator=LogisticRegression(C=1))] (&apos;RFE&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RFECV(estimator=LogisticRegression(C=1))] (&apos;RFECV&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RadiusNeighborsClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RadiusNeighborsRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RadiusNeighborsTransformer()] (&apos;RadiusNeighborsTransformer&apos;, NotFittedError(&quot;This RadiusNeighborsTransformer instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RandomForestClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RandomForestRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RandomTreesEmbedding()] (&apos;RandomTreesEmbedding&apos;, NotFittedError(&quot;This RandomTreesEmbedding instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RegressorChain(base_estimator=Ridge())] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[Ridge()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RidgeCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RidgeClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RidgeClassifierCV()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[RobustScaler()] (&apos;RobustScaler&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SGDClassifier()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SGDOneClassSVM()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SGDRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SVC()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SVR()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectFdr()] (&apos;SelectFdr&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectFpr()] (&apos;SelectFpr&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectFromModel(estimator=SGDRegressor(random_state=0))] (&apos;SelectFromModel&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectFwe()] (&apos;SelectFwe&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectKBest()] (&apos;SelectKBest&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelectPercentile()] (&apos;SelectPercentile&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SelfTrainingClassifier(base_estimator=LogisticRegression(C=1))] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SequentialFeatureSelector(estimator=LogisticRegression(C=1))] (&apos;SequentialFeatureSelector&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[ShrunkCovariance()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SimpleImputer()] (&apos;SimpleImputer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SkewedChi2Sampler()] (&apos;SkewedChi2Sampler&apos;, NotFittedError(&quot;This SkewedChi2Sampler instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SparsePCA()] (&apos;SparsePCA&apos;, NotFittedError(&quot;This SparsePCA instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SparseRandomProjection()] (&apos;SparseRandomProjection&apos;, TypeError(&quot;&apos;str&apos; object cannot be interpreted as an integer&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SpectralBiclustering()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SpectralClustering()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SpectralCoclustering()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SpectralEmbedding()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[SplineTransformer()] (&apos;SplineTransformer&apos;, AttributeError(&quot;&apos;SplineTransformer&apos; object has no attribute &apos;bsplines_&apos;&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[StackingClassifier(estimators=[(&apos;est1&apos;,LogisticRegression(C=0.1)),(&apos;est2&apos;,LogisticRegression(C=1))])] (&apos;StackingClassifier&apos;, AttributeError(&quot;&apos;StackingClassifier&apos; object has no attribute &apos;_n_feature_outs&apos;&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[StackingRegressor(estimators=[(&apos;est1&apos;,Ridge(alpha=0.1)),(&apos;est2&apos;,Ridge(alpha=1))])] (&apos;StackingRegressor&apos;, AttributeError(&quot;&apos;StackingRegressor&apos; object has no attribute &apos;_n_feature_outs&apos;&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[StandardScaler()] (&apos;StandardScaler&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TSNE()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TfidfTransformer()] (&apos;TfidfTransformer&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TfidfVectorizer()] (&apos;TfidfVectorizer&apos;, NotFittedError(&apos;Vocabulary not fitted or provided&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TheilSenRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TransformedTargetRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TruncatedSVD()] (&apos;TruncatedSVD&apos;, NotFittedError(&quot;This TruncatedSVD instance is not fitted yet. Call &apos;fit&apos; with appropriate arguments before using this estimator.&quot;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[TweedieRegressor()] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[VarianceThreshold()] (&apos;VarianceThreshold&apos;, ValueError(&apos;Unable to generate feature names without n_features_in_&apos;))
<font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[VotingClassifier(estimators=[(&apos;est1&apos;,LogisticRegression(C=0.1)),(&apos;est2&apos;,LogisticRegression(C=1))])] <font color="#26A269">PASSED</font>
sklearn/tests/test_common.py::test_error_check_get_feature_names_out[VotingRegressor(estimators=[(&apos;est1&apos;,Ridge(alpha=0.1)),(&apos;est2&apos;,Ridge(alpha=1))])] <font color="#26A269">PASSED</font>

<font color="#A2734C">============================================================= </font><font color="#26A269">197 passed</font>, <font color="#A2734C"><b>9400 deselected</b></font>, <font color="#A2734C"><b>76 warnings</b></font><font color="#A2734C"> in 3.57s =============================================================</font>
</pre>
</details>
@jpangas Maybe you can start with one PR with the new test in test_common.py ? We will need it to verify that the fixes are correctly implemented.
I agree with @albuzenet . 

You can start with one PR that contains the test which runs for all estimators (in a parameterized way).
For each estimator assert that `NotFittedError` is raised. 
For the ones where this is not raised, you can simply xfail the test ( for e.g https://github.com/scikit-learn/scikit-learn/blob/670133dbc42ebd9f79552984316bc2fcfd208e2e/sklearn/tests/test_docstrings.py#L379) 

If you wish to collaborate on this, hit me up on scikit-learn discord channel :)

I raised a PR #25221 containing test case. 

@jpangas The list you posted is incomplete. Can you update the list using the `CLASS_NOT_FITTED_ERROR_IGNORE_LIST` in my PR? 

@scikit-learn/core-devs I believe once this PR is merged, it could qualify as `Easy` / `good first issue`. WDYT?
Update: The test that checks and ensures a `NotFittedError` is raised was successfully merged in PR #25223 . We can now work on the estimators that produce inconsistent errors @Kshitij68 @albuzenet 