Go ahead, submit a PR.

On 21 February 2017 at 12:12, Mamy Ratsimbazafy <notifications@github.com>
wrote:

> The documentation
> <http://scikit-learn.org/stable/modules/generated/sklearn.manifold.locally_linear_embedding.html>
> mentions that sklearn.manifold.LocallyLinearEmbedding should support
> sparse matrix.
>
> The error comes from the 5 occurences
> <https://github.com/scikit-learn/scikit-learn/blob/14031f6/sklearn/manifold/locally_linear.py#L629>
> of check_array from sklearn.utils.validation.
>
> If documentation is correct check_array should be called with
> accept_sparse=True
> Check array input
> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/utils/validation.py#L269>
>
> I can submit a PR.
>
> Isomap also accepts sparse matrix according to documentation on fit and
> fit_transform methods.
> Given that SpectralEmbedding also uses the arpack solver, I guess that it
> also should accept sparse matrices.
>
> Check of check_array calls in the manifold subfolder
>
> /usr/lib/python3.6/site-packages/sklearn/manifold  $  grep 'check_array' *.py -n
> isomap.py:9:from ..utils import check_array
> isomap.py:103:        X = check_array(X)
> isomap.py:202:        X = check_array(X)
> locally_linear.py:11:from ..utils import check_random_state, check_array
> locally_linear.py:42:    X = check_array(X, dtype=FLOAT_DTYPES)
> locally_linear.py:43:    Z = check_array(Z, dtype=FLOAT_DTYPES, allow_nd=True)
> locally_linear.py:629:        X = check_array(X, dtype=float)
> locally_linear.py:688:        X = check_array(X)
> mds.py:14:from ..utils import check_random_state, check_array, check_symmetric
> mds.py:229:    similarities = check_array(similarities)
> mds.py:394:        X = check_array(X)
> spectral_embedding_.py:14:from ..utils import check_random_state, check_array, check_symmetric
> spectral_embedding_.py:280:        laplacian = check_array(laplacian, dtype=np.float64,
> spectral_embedding_.py:283:        ml = smoothed_aggregation_solver(check_array(laplacian, 'csr'))
> spectral_embedding_.py:295:        laplacian = check_array(laplacian, dtype=np.float64,
> spectral_embedding_.py:472:        X = check_array(X, ensure_min_samples=2, estimator=self)
> t_sne.py:18:from ..utils import check_array
> t_sne.py:706:            X = check_array(X, accept_sparse=['csr', 'csc', 'coo'],
>
> For reference, my backtrace
>
> Input training data has shape:  (49352, 15)
> Input test data has shape:      (74659, 14)........
> Traceback (most recent call last):
>   File "main.py", line 108, in <module>
>     X, X_test, y, tr_pipeline, select_feat, cache_file)
>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/preprocessing.py", line 13, in preprocessing
>     x_trn, x_val, x_test = feat_selection(select_feat, x_trn, x_val, X_test)
>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 61, in feat_selection
>     trn, val, tst = zip_with(_concat_col, tuples_trn_val_test)
>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 23, in zip_with
>     return starmap(f, zip(*list_of_tuple))
>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 76, in _feat_transfo
>     trn = Transformer.fit_transform(train[sCol])
>   File "/usr/lib/python3.6/site-packages/sklearn/pipeline.py", line 303, in fit_transform
>     return last_step.fit_transform(Xt, y, **fit_params)
>   File "/usr/lib/python3.6/site-packages/sklearn/manifold/locally_linear.py", line 666, in fit_transform
>     self._fit_transform(X)
>   File "/usr/lib/python3.6/site-packages/sklearn/manifold/locally_linear.py", line 629, in _fit_transform
>     X = check_array(X, dtype=float)
>   File "/usr/lib/python3.6/site-packages/sklearn/utils/validation.py", line 380, in check_array
>     force_all_finite)
>   File "/usr/lib/python3.6/site-packages/sklearn/utils/validation.py", line 243, in _ensure_sparse_format
>     raise TypeError('A sparse matrix was passed, but dense 'TypeError: A sparse matrix was passed, but dense data is required. Use X.toarray() to convert to a dense numpy array.
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8416>, or mute the
> thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6-I0nAfZTcT9mgjprq2bH97AJtOzks5rejoIgaJpZM4MGxJD>
> .
>

Thanks.

(Not that i've confirmed that these will actually work with sparse matrices
and I'm not familiar with them.)

On 21 February 2017 at 14:14, Joel Nothman <joel.nothman@gmail.com> wrote:

> Go ahead, submit a PR.
>
> On 21 February 2017 at 12:12, Mamy Ratsimbazafy <notifications@github.com>
> wrote:
>
>> The documentation
>> <http://scikit-learn.org/stable/modules/generated/sklearn.manifold.locally_linear_embedding.html>
>> mentions that sklearn.manifold.LocallyLinearEmbedding should support
>> sparse matrix.
>>
>> The error comes from the 5 occurences
>> <https://github.com/scikit-learn/scikit-learn/blob/14031f6/sklearn/manifold/locally_linear.py#L629>
>> of check_array from sklearn.utils.validation.
>>
>> If documentation is correct check_array should be called with
>> accept_sparse=True
>> Check array input
>> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/utils/validation.py#L269>
>>
>> I can submit a PR.
>>
>> Isomap also accepts sparse matrix according to documentation on fit and
>> fit_transform methods.
>> Given that SpectralEmbedding also uses the arpack solver, I guess that
>> it also should accept sparse matrices.
>>
>> Check of check_array calls in the manifold subfolder
>>
>> /usr/lib/python3.6/site-packages/sklearn/manifold  $  grep 'check_array' *.py -n
>> isomap.py:9:from ..utils import check_array
>> isomap.py:103:        X = check_array(X)
>> isomap.py:202:        X = check_array(X)
>> locally_linear.py:11:from ..utils import check_random_state, check_array
>> locally_linear.py:42:    X = check_array(X, dtype=FLOAT_DTYPES)
>> locally_linear.py:43:    Z = check_array(Z, dtype=FLOAT_DTYPES, allow_nd=True)
>> locally_linear.py:629:        X = check_array(X, dtype=float)
>> locally_linear.py:688:        X = check_array(X)
>> mds.py:14:from ..utils import check_random_state, check_array, check_symmetric
>> mds.py:229:    similarities = check_array(similarities)
>> mds.py:394:        X = check_array(X)
>> spectral_embedding_.py:14:from ..utils import check_random_state, check_array, check_symmetric
>> spectral_embedding_.py:280:        laplacian = check_array(laplacian, dtype=np.float64,
>> spectral_embedding_.py:283:        ml = smoothed_aggregation_solver(check_array(laplacian, 'csr'))
>> spectral_embedding_.py:295:        laplacian = check_array(laplacian, dtype=np.float64,
>> spectral_embedding_.py:472:        X = check_array(X, ensure_min_samples=2, estimator=self)
>> t_sne.py:18:from ..utils import check_array
>> t_sne.py:706:            X = check_array(X, accept_sparse=['csr', 'csc', 'coo'],
>>
>> For reference, my backtrace
>>
>> Input training data has shape:  (49352, 15)
>> Input test data has shape:      (74659, 14)........
>> Traceback (most recent call last):
>>   File "main.py", line 108, in <module>
>>     X, X_test, y, tr_pipeline, select_feat, cache_file)
>>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/preprocessing.py", line 13, in preprocessing
>>     x_trn, x_val, x_test = feat_selection(select_feat, x_trn, x_val, X_test)
>>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 61, in feat_selection
>>     trn, val, tst = zip_with(_concat_col, tuples_trn_val_test)
>>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 23, in zip_with
>>     return starmap(f, zip(*list_of_tuple))
>>   File "/home/ml/machinelearning_projects/Kaggle_Compet/Renthop_Apartment_interest/src/star_command.py", line 76, in _feat_transfo
>>     trn = Transformer.fit_transform(train[sCol])
>>   File "/usr/lib/python3.6/site-packages/sklearn/pipeline.py", line 303, in fit_transform
>>     return last_step.fit_transform(Xt, y, **fit_params)
>>   File "/usr/lib/python3.6/site-packages/sklearn/manifold/locally_linear.py", line 666, in fit_transform
>>     self._fit_transform(X)
>>   File "/usr/lib/python3.6/site-packages/sklearn/manifold/locally_linear.py", line 629, in _fit_transform
>>     X = check_array(X, dtype=float)
>>   File "/usr/lib/python3.6/site-packages/sklearn/utils/validation.py", line 380, in check_array
>>     force_all_finite)
>>   File "/usr/lib/python3.6/site-packages/sklearn/utils/validation.py", line 243, in _ensure_sparse_format
>>     raise TypeError('A sparse matrix was passed, but dense 'TypeError: A sparse matrix was passed, but dense data is required. Use X.toarray() to convert to a dense numpy array.
>>
>> —
>> You are receiving this because you are subscribed to this thread.
>> Reply to this email directly, view it on GitHub
>> <https://github.com/scikit-learn/scikit-learn/issues/8416>, or mute the
>> thread
>> <https://github.com/notifications/unsubscribe-auth/AAEz6-I0nAfZTcT9mgjprq2bH97AJtOzks5rejoIgaJpZM4MGxJD>
>> .
>>
>
>

I traced through and it looks like it should all work with sparse input. I'm added the accept sparse and some tests for sparse input. Will submit a pull request presuming the tests pass.
great!

On 8 Mar 2017 8:23 am, "Leland McInnes" <notifications@github.com> wrote:

> I traced through and it looks like it should all work with sparse input.
> I'm added the accept sparse and some tests for sparse input. Will submit a
> pull request presuming the tests pass.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8416#issuecomment-284863646>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6y2F6MUdJ_HAcHvYMdr43A6TbJjyks5rjcrLgaJpZM4MGxJD>
> .
>
