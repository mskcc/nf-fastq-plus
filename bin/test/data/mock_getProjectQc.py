#!/usr/bin/env python

MOCK_RESP = [
   {
      "samples":[
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_6"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_3"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_4"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_7"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_2"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_1"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_5"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0406_BHC5G7BBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_8"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_4"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_2"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_1"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_1"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_2"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_3"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_4"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_5"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_6"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_7"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"JAX_0374_BHFFHMBBXY_A1",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_8"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0414_AHFHJMBBXY",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_8"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_6"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_3"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_7"
         },
         {
            "project":"05240_W",
            "recipe":"IDT_Exome_v1_FP_Viral_Probes",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY",
               "qcStatus":"Failed",
               "reviewed":"false"
            },
            "baseId":"05240_W_5"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_3"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_5"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_6"
         },
         {
            "project":"05240_W",
            "recipe":"WholeExomeSequencing",
            "qc":{
               "run":"PITT_0415_BHFGNVBBXY_A1",
               "qcStatus":"IGO-Complete",
               "reviewed":"false"
            },
            "baseId":"05240_W_7"
         }
      ],
      "requestId":"05240_W",
      "sampleNumber":8,
      "restStatus":"SUCCESS"
   }
]
