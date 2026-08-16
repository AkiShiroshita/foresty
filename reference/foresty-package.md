# foresty: Forest Plots and Subgroup Effects from Fitted Regression Models

An interaction p-value says whether two exposures depart from a common
model, not what the exposure does inside each subgroup, and a reader
cannot tell those apart from the p-value alone. Pass a fitted model and
the name of the exposure, and 'foresty' draws the forest plot of its
effect; name one effect modifier as well and the model is updated with
the interaction term, the exposure effect is estimated separately within
every level of the modifier as a linear combination of the coefficients,
and the levels are drawn one above the other with the joint test of the
interaction reported beside them, so that the estimate and the test are
read together. One exposure and one modifier at a time: the interaction
reported is always a two-way one. The figure is laid out as a paper lays
one out, the rows of the plot and of the table of numbers beside it
aligned on one scale and each column of text no wider than what it
carries, in a style that can be set to a journal's. The same interaction
model is written to a self-contained HTML page carrying the subgroup
estimates, the joint test, and the full coefficient table, so that what
the p-value was summarising can be inspected. Linear combinations and
their tests are computed by the 'car' package rather than reimplemented
here. Models fitted by stats::glm(), stats::lm(), the 'survival'
package, the 'lme4' package and the 'geepack' package are supported,
along with any other fit that supplies coef() and vcov(). Fits from the
'rms' package are not, and are refused with the function that fits the
same model named in their place.

## See also

Useful links:

- <https://github.com/AkiShiroshita/foresty>

- <https://akishiroshita.github.io/foresty/>

- Report bugs at <https://github.com/AkiShiroshita/foresty/issues>

## Author

**Maintainer**: Akihiro Shiroshita <akihirokun8@gmail.com> \[copyright
holder\]

Authors:

- Akihiro Shiroshita <akihirokun8@gmail.com> \[copyright holder\]

- Yuki Kataoka <youkiti@gmail.com>
