
context("diversity estimates")
test_that("diversity estimates", {
    skip_if_not(requireNamespace("vegan", quietly = TRUE))
    data("esophagus")
    esophagus <- estimateDiversity(esophagus, threshold = 0.473)
    cd <- colData(esophagus)
    expect_equal(unname(round(cd$shannon, 5)), c(2.24937, 2.76239, 2.03249))
    expect_equal(unname(round(cd$simpson_diversity, 6)),
                 c(0.831372, 0.903345, 0.665749))
    expect_equal(unname(round(cd$inv_simpson, 5)),
                 c(5.93021, 10.34606, 2.99177))
    expect_equal(unname(round(cd$richness, 0)), c(28, 33, 38))
    expect_equal(unname(round(cd$chao1, 4)), c(39.1429, 37.5000, 71.0000))
    expect_equal(unname(round(cd$ACE, 4)), c(49.0970, 40.9465, 88.9768))
    expect_equal(unname(round(cd$coverage, 0)), c(2,3,1))
    expect_equal(estimateDiversity(esophagus,
                                   index = "coverage",
                                   threshold = 0.9),
                 estimateCoverage(esophagus))
})
