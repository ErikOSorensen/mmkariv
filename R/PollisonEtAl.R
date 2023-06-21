# The functions in this file are collected from: 
# Polisson, Matthew, Quah, John K.-H., and Renou, Ludovic. Data and Code for: 
# Revealed Preferences over Risk and Uncertainty. Nashville, TN: American Economic 
# Association [publisher], 2020. Ann Arbor, MI: Inter-university Consortium for 
# Political and Social Research [distributor], 
# 2020-05-27. https://doi.org/10.3886/E112146V1
# This replication package was licensed under a Creative Commons Attribution 4.0 International 
# (CC BY 4.0) License.
#
#
# The arguments supplied to the relevant ccei functions are (p, x) or (p, x, pi)
# p: prices, matrix in the form k x N, with N number of decisions and k goods/states
# x: quantities chosen, matrix in the form k x N, with N number of decisions and k goods/states
# pi: Vector of probabilities, k x 1, when k corresponds to the number of states. Applies 
#     to the functions that are explicit about stochastic state interpretation instead of abstract goods.

warshall = function (R0) {
  R = R0;
  for (k in 1 : dim (R)[1]) {
    for (i in (1 : dim (R)[1])[-k]) { 
      if (R[i, k] == 1) {
        for (j in (1 : dim (R)[1])[-k]) {
          if (R[i, j] == 0) {
            R[i, j] = R[k, j];
          }
        }
      }
    }
  }
  result = R;
  return (result);
}

garp = function (p, x, e) {
        R0 = NaN * matrix (1, dim (p)[2], dim (p)[2]);
        P0 = NaN * matrix (1, dim (p)[2], dim (p)[2]);
        for (i in 1 : dim (p)[2]) {
                for (j in 1 : dim (p)[2]) {
                        R0[i, j] = e * sum (p[, i] * x[, i]) >= sum (p[, i] * x[, j]);
                        P0[i, j] = e * sum (p[, i] * x[, i]) > sum (p[, i] * x[, j]);
                }
        }
        R = warshall (R0);
        result = 1;
        for (i in 1 : dim (p)[2]) {
                for (j in 1 : dim (p)[2]) {
                        if (R[i, j] == 1 & P0[j, i] == 1) {
                                result = 0;
                                break;
                        }
                }
                if (result == 0) {
                        break;
                }
        }
        return (result);
}

fgarp = function (p, x, pi, e) {
  y = rbind (x[2,], x[1,]);
  if (pi[1, 1] != pi[2, 1]) {
    if (pi[1, 1] < pi[2, 1]) {
      y[, (x[1,] <= x[2,])] = x[, (x[1,] <= x[2,])];
    } else  {
      y[, (x[2,] <= x[1,])] = x[, (x[2,] <= x[1,])];
    }
  }
  R0 = NaN * matrix (1, dim (p)[2], dim (p)[2]);
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (p)[2]) {
      R0[i, j] = (e * sum (p[, i] * x[, i]) >= sum (p[, i] * x[, j]) | e * sum (p[, i] * x[, i]) >= sum (p[, i] * y[, j]));
    }
  }
  R = warshall (R0);
  P0 = NaN * matrix (1, dim (p)[2], dim (p)[2]);
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (p)[2]) {
      if (pi[1, 1] == pi[2, 1]) {
        P0[i, j] = (e * sum (p[, i] * x[, i]) > sum (p[, i] * x[, j]) | e * sum (p[, i] * x[, i]) > sum (p[, i] * y[, j]));
      } else {
        P0[i, j] = (e * sum (p[, i] * x[, i]) > sum (p[, i] * x[, j]) | (e * sum (p[, i] * x[, i]) >= sum (p[, i] * y[, j]) & sum (x[, j] == y[, j]) != dim (p)[1]));
      }
    }
  }
  result = 1;
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (p)[2]) {
      if (R[i, j] == 1 & P0[j, i] == 1) {
        result = 0;
        break;
      }
    }
    if (result == 0) {
      break;
    }
  }
  return (result);
}


eu = function (p, x, pi, e) {
  cons = cons_eu (p, x, pi, e);
  A = cons[, 1 : dim (cons)[2] - 1];
  b = cons[, dim (cons)[2]];
  lp = make.lp (dim (A)[1], dim (A)[2]);
  for (i in 1 : dim (A)[2]) {
    set.column (lp, i, A[, i]);
  }
  set.constr.type (lp, rep ("<=", dim (A)[1]));
  set.bounds (lp, lower = rep (1, dim (A)[2]));
  set.rhs (lp, b);
  exitflag = solve (lp);
  if (exitflag == 0) {
    result = 1;
  } else {
    result = 0;
  }
  return (result);
}

ccei_garp = function (p, x) {
  estar = 1;
  if (garp (p, x, estar) == 0) {
    eL = 0;
    eH = 1;
    while (eH - eL > 1e-6) {
      e = (eL + eH) / 2;
      if (garp (p, x, e) == 1) {
        estar = e;
        eL = e;
      } else {
        estar = eL;
        eH = e;
      }
    }
  }
  result = estar;
  return (result);
}

ccei_fgarp = function (p, x, pi) {
  estar = 1;
  if (fgarp (p, x, pi, estar) == 0) {
    eL = 0;
    eH = 1;
    while (eH - eL > 1e-6) {
      e = (eL + eH) / 2;
      if (fgarp (p, x, pi, e) == 1) {
        estar = e;
        eL = e;
      } else {
        estar = eL;
        eH = e;
      }
    }
  }
  result = estar;
  return (result);
}

ccei_eu = function (p, x, pi) {
  estar = 1;
  if (eu (p, x, pi, estar) == 0) {
    eL = 0;
    eH = 1;
    while (eH - eL > 1e-6) {
      e = (eL + eH) / 2;
      if (eu (p, x, pi, e) == 1) {
        estar = e;
        eL = e;
      } else {
        estar = eL;
        eH = e;
      }
    }
  }
  result = estar;
  return (result);
}

cons_eu = function (p, x, pi, e) {
  grid = expand.grid (sort (unique (c (0, x))), sort (unique (c (0, x))));
  A = matrix (0, dim (grid)[1] * dim (p)[2], length (unique (c (0, x))));
  A1 = matrix (0, dim (A)[1], dim (A)[2]);
  for (i in 1 : (dim (A)[2] * dim (p)[2])) {
    A1[((i - 1) * dim (A)[2] + 1) : (i * dim (A)[2]), 1 : dim (A)[2]] = diag (dim (A)[2]) * pi[1, 1];
  }
  A2 = matrix (0, dim (A)[1], dim (A)[2]);
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (A)[2]) {
      A2[((i - 1) * dim (grid)[1] + (j - 1) * dim (A)[2] + 1) : ((i - 1) * dim (grid)[1] + j * dim (A)[2]), j] = matrix (1, dim (A)[2], 1) * pi[2, 1];
    }
  }
  A3 = matrix (0, dim (A)[1], dim (A)[2]);
  for (i in 1 : dim (p)[2]) {
    A3[((i - 1) * dim (grid)[1] + 1) : (i * dim (grid)[1]), 1 : dim (A)[2]] = t (matrix (t (-((x[1, i] == sort (unique (c (0, x)))) * pi[1, 1] + (x[2, i] == sort (unique (c (0, x)))) * pi[2, 1])), dim (A)[2], dim (grid)[1]));
  }
  A = A1 + A2 + A3;
  b = matrix (0, dim (A)[1], 1);
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (grid)[1]) {
      b[(i - 1) * dim (grid)[1] + j, 1] = (sum (p[, i] * c (grid[j, 1], grid[j, 2])) < e * sum (p[, i] * x[, i])) * -1;
    }
  }
  cons = cbind (A, b);
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (grid)[1]) {
      cons[(i - 1) * dim (grid)[1] + j,] = (sum (p[, i] * c (grid[j, 1], grid[j, 2])) <= e * sum (p[, i] * x[, i])) * cons[(i - 1) * dim (grid)[1] + j,];
    }
  }
  for (i in 1 : dim (p)[2]) {
    for (j in 1 : dim (grid)[1]) {
      cons[(i - 1) * dim (grid)[1] + j,] = (x[1, i] < grid[j, 1] | x[2, i] < grid[j, 2]) * cons[(i - 1) * dim (grid)[1] + j,]; 
    }
  }
  cons = cons[rowSums (cons != 0) != 0,];
  A4 = matrix (0, dim (A)[2] - 1, dim (A)[2]);
  A4[, 1 : (dim (A)[2] - 1)] = diag (dim (A)[2] - 1);
  A5 = matrix (0, dim (A)[2] - 1, dim (A)[2]);
  A5[, 2 : dim (A)[2]] = -diag (dim (A)[2] - 1);
  cons = rbind (cons, cbind (A4 + A5, matrix (-1, dim (A4)[1], 1)));
  result = cons;
  return (result);
}