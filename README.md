# alignment_models
Determining the effect of MSA on information theoretic criterion model selection.

We evaluate whether the selected model is influenced by MSA using a Guidance2-based approach to generate 50 perturbed MSAs per dataset, where each dataset has AA, nucleotide, _and codon_ (back-translated AA) versions. We determine the best-fitting model under AIC, AICc, and BIC for each perturbed alignment and ask how many models are selected. We compare stability among each IC as well as across data type (AA, codon, nucleotide).






