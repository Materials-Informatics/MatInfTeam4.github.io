---
layout: post

title: Updated Problem Statement
category: blog

author:
  name: Patxi Fernandez-Zelaia
  bio: Domain Expert
  image: patxi.png

---

## Process

Machining processing induces large strains at high-strain rate and elevated temperatures. A 2D idealization is shown below.

![Image](http://matinfteam4.github.io/images/geometry.png)

There are three independent variables in each experiment that control strain, rate and temperature in a non-unique fashion,

1. Depth of cut (t)
2. Machining surface velocity (V)
3. Tool angle (\theta)

## Structure Changes

[<img src="http://ars.els-cdn.com/content/image/1-s2.0-S1359645409004807-gr4.jpg" width="600px" />](http://www.sciencedirect.com/science/article/pii/S1359645409004807)

1. Large range of grain refinement spanning from the initial micrometer scale down to the nanometer scale within shear bands
2. Evolution of grain aspect ratio
3. Increase in dislocation density at the atomistic scale
4. Evolution of grain boundary misorientation
5. Twinning

## Experimental Data

Machining experiments were performed on grade 5 commercial purity titanium. The initial microstructure has an average grain size of roughly 30-40 um and is shown below.

[![Image](http://matinfteam4.github.io/images/virgin.png)](http://matinfteam4.github.io/images/virgin.png)

The experimental matrix varies the depth of cut (t) and surface velocity (V),

|               | V = 0.33 m/s | V = 1.00 m/s | V = 1.67 m/s | V = 2.33 m/s | V = 3.00 m/s |
| ------------- | ------------ | ------------ | ------------ | ------------ | ------------ |
| t=0.1 mm      |      x       |      x       |       x      |      x       |       x      |
| t=0.2 mm      |      x       |      x       |       x      |      x       |       x      |
| t=0.3 mm      |      x       |      x       |       x      |      x       |       x      |

Chips collected from each experiment have been mounted, polished and etched to reveal phase boundary structure. A sample micrograph is shown below. All images were produced from optical microscopy.


[![Image](http://matinfteam4.github.io/images/CpTi-22-5X.png)](http://matinfteam4.github.io/images/CpTi-22-5X.png)

Note that the initial grain size is roughly 30-40 um and discernible features in the optical micrographs range from 1-10 um.

## Methods sections

Given that images are limited by the resolution of optical microscopy the available quantifiable structure metrics are

1. Grain size
2. Grain morphology

A key issue of this problem is that there is a spatial variation in grain size scale from micron to nanometer scale (within shear bands). As such optical microscopy has limited utility for capturing nanocrystalline features. 

The previous approach was to assume that a homogeneous region exists away from shear bands and to focus our efforts on these regions. This is shown schematically below.

![Image](http://matinfteam4.github.io/images/analysis_v1.png)

However this assumption may be poor as gradients are large not only between shear bands but also traversing the specimen from bottom to top.

A revised strategy is to address the gradients directly by assuming the following coordinates which are normal to the gradient features.

![Image](http://matinfteam4.github.io/images/analysis_revised.png)

The plan for quantifying structure statistics is to:

1. Segment micrographs - Processing images to identify phase boundaries (twins or grain boundaries). 

2. Quantify statistics - Use n-point statistics to explore process-structure linkages and quantify the relevant microstructure function(s). This will also include reducing the order of the statistics possibly through principal component analysis (PCA).

## Deliverables

1. Generate segmented data set from micrographs
2. Extract pathways in n-point statistic space corresponding to specific processes
