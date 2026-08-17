# foresty: Forest Plots and Subgroup Effects from Fitted Regression Models

Draws forest plots of exposure effects from fitted regression models.
Name an exposure and 'foresty' plots its effect. Name an effect modifier
as well and it refits the model with the interaction term, estimates the
exposure effect within each level of the modifier as a linear
combination of the coefficients, and reports the joint interaction test
beside those estimates. It takes one exposure and one modifier at a
time, so the interaction is always a two-way one. Rows of the plot and
of the table beside it share one scale, in a layout that can follow a
journal's house style. The same results go to a self-contained HTML page
holding the subgroup estimates, the joint test and the coefficient
table. The 'car' package computes the linear combinations and their
tests. Models fitted by stats::glm(), stats::lm(), the 'survival'
package, the 'lme4' package and the 'geepack' package are supported, as
is any fit supplying coef() and vcov(). Fits from the 'rms' package are
refused, naming the function that fits the same model in their place.

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
