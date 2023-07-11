# devbox-demo

DevBox tutorial repo.

DevBox allows association of pools with
    - devbox image definitions
    - network associations
    - user profile (user/admin)

Custom imagage are interestting to pre-install all required dev software
    - the custom-image-tuto folder contains code extracts from lean.microsoft.com used to create a vm template with azure builder
     - the custom-image-bicep folder contains bicep templates derived from the  https://github.com/ms-sambell/dev-box-custom-image-demo.git repo 


> Note : Building the image with post-install scripts that are run as elevated, seem to 
