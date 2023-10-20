# Oscillation controls

Put the model of the 2nd order resonant converter

Discuss the challenges when adding a rectifier


Discuss what happen when it becomes a 3rd order. Look at Deng2014 could be the good thing.

## Introduction

> [FROM ADHS]

In this paper, a novel unifying input-dependent coordinate transformation is proposed to analyze parallel and series resonant converters.
The advantage is that the transformed dynamics, for both architectures, is described by the same hybrid equations, thus unifying the analysis. 
These hybrid equations naturally suggest a specific state-plane feedback control law, to ensure a self-oscillating closed-loop steady state.
We prove here, for certain parameters selections, that the results in {cite:p}`BisoffiECC16` prove almost global attractivity of a unique nontrivial limit cycle, associated to the desired resonant output. 
The specific oscillation amplitude and frequency can be adjusted using a single parameter that describes the switching surface in the newly proposed input-dependent set of coordinates. 
In the paper we also investigate the output voltage or current and frequency, as a function the control parameter, numerically showing that it has a monotonic behavior.
Finally, we briefly address possible 
issues emerging with analog or digital implementations.


> [FROM TCST]

In this work we extend {cite:p}`ADHS` in several important directions: first, we generalize the main theorem of {cite:p}`ADHS` about the existence of the unique limit cycle and our new proof, based on a different Lyapunov argument, applies to any reference $\theta \in (0,\pi]$.
Then, while {cite:p}`ADHS` only reported simulation results, we report here on the development of an experimental device implementing our feedback on a SRC architecture. 
Finally, since only the PRC solution was simulated in {cite:p}`ADHS`, we perform SRC simulations here and show desirable matching of the simulation and experimental results.


### Notation
<!-- $\mathbb{R}$ and $\mathbb{Z}$ denote, respectively, the sets of real and integer numbers. $\mathbb{R}_{>0}$ ($\mathbb{R}_{\geq 0}$) and $\mathbb{Z}_{>0}$ ($\mathbb{Z}_{\geq 0}$) denote, respectively the positive (non-negative) real and integer numbers. -->
$\mathbb{R}$ ($\mathbb{R}_{>0}$) [$\mathbb{R}_{\geq 0}$] and $\mathbb{Z}$ ($\mathbb{Z}_{>0}$) [$\mathbb{Z}_{\geq 0}$] are the sets of (positive) [non-negative] real and integer numbers.  
$\mathbb{R}^n$ denotes the $n$-dimensional Euclidean space. Given two vectors $u \in \mathbb{R}^n$ and $w\in \mathbb{R}^m$, $u^\top$ denotes the transpose of $u$, and $(u,w) := \begin{bmatrix} u^\top \; w^\top \end{bmatrix}^\top$ denotes their stacking.
Given a (continuous, discrete, or hybrid) signal $x$, $\dot x$ denotes its derivative with respect to continuous time $t$, while $x^+$ denotes its next value with respect to discrete time $j$.






