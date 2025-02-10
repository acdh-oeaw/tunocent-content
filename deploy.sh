ssh tunocent@hephaistos.arz.oeaw.ac.at "cd tunocent-content/ && git pull && \
cd ../basex/webapp/vicav && ln -f ../../../tunocent-content/vicav_projects/* ./vicav_projects/ &&\
 ln -f ../../../tunocent-content/vicav_lingfeatures/tunocent/* ./vicav_lingfeatures/tunocent && \
 ln -f ../../../tunocent-content/vicav_samples/tunocent/* ./vicav_samples/tunocent/ &&\
 ln -f ../../../tunocent-content/vicav_biblio/tunocent/* ./vicav_biblio/tunocent/ &&\
 ln -f ../../../tunocent-content/vicav_texts/tunocent/* ./vicav_texts/tunocent/ &&\
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/* ./vicav_profiles/tunocent &&\
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/*.jpg ./images &&\
 ln -f ../../../tunocent-content/vicav_texts/tunocent/*.jpg ./images &&\
 ln -f ../../../tunocent-content/vicav_texts/tunocent/*.jpeg ./images &&\
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/*.jpg ./images
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/*.jpeg ./images
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/thumb/*.jpeg ./images/thumb
 ln -f ../../../tunocent-content/vicav_profiles/tunocent/thumb/*.jpg ./images/thumb
/home/tunocent/basex/bin/basexclient -Uadmin -Padmin -p11984 -c /home/tunocent/tunocent-content/deployment/deploy-tunocent-content.bxs"

