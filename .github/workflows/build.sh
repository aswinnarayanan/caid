#!/bin/bash

pip install --no-cache-dir ${{ env.NEURODOCKER_TARBALL }} --upgrade
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
git pull github ${GITHUB_REF} --ff-only
cd recipes/${{ env.APPLICATION }}
/bin/bash build.sh
git add .
git commit -m "$GITHUB_SHA"
git push github HEAD:${GITHUB_REF}
for dockerfile in ./*.Dockerfile; do
  echo $dockerfile
  IMAGEID=docker.pkg.github.com/${{ github.repository }}/$(basename $dockerfile .Dockerfile)
  IMAGEID=$(echo $IMAGEID | tr '[A-Z]' '[a-z]')
  echo "${{ secrets.GITHUB_TOKEN }}" | docker login docker.pkg.github.com -u ${{ github.actor }} --password-stdin
  docker pull $IMAGEID:latest || true
  docker build . --file $dockerfile --tag $IMAGEID:latest --cache-from $IMAGEID:latest
  docker push $IMAGEID:latest
done