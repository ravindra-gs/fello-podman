#!/bin/bash

setup_fello_project() {
    source .env

    declare -A repo_paths
    declare -A clone_cmds

    # Fill in the actual environment variable values and git clone commands
    repo_paths=(
        [API_FELLO_COM_PATH]="$API_FELLO_COM_PATH"
        [IMS_FELLO_COM_PATH]="$IMS_FELLO_COM_PATH"
        [V4_FELLO_COM_PATH]="$V4_FELLO_COM_PATH"
        [ARAMARK_FELLO_COM_PATH]="$ARAMARK_FELLO_COM_PATH"
        [EVENTBRITE_FELLO_COM_PATH]="$EVENTBRITE_FELLO_COM_PATH"
        [FELLO_COM_PATH]="$FELLO_COM_PATH"
        [GIVESMART_FELLO_COM_PATH]="$GIVESMART_FELLO_COM_PATH"
        [LEVY_FELLO_COM_PATH]="$LEVY_FELLO_COM_PATH"
        [MOBILECAUSE_FELLO_COM_PATH]="$MOBILECAUSE_FELLO_COM_PATH"
        [SHOPIFY_FELLO_COM_PATH]="$SHOPIFY_FELLO_COM_PATH"
        [SHOPIFYCA_FELLO_COM_PATH]="$SHOPIFYCA_FELLO_COM_PATH"
        [SQURE_FELLO_COM_PATH]="$SQURE_FELLO_COM_PATH"
        [SQURECA_FELLO_COM_PATH]="$SQURECA_FELLO_COM_PATH"
        [TASSEL_FELLO_COM_PATH]="$TASSEL_FELLO_COM_PATH"
        [TASSELCA_FELLO_COM_PATH]="$TASSELCA_FELLO_COM_PATH"
    )

    clone_cmds=(
        [API_FELLO_COM_PATH]="git clone git@github.com:felloco/fc-inventory-api.git $API_FELLO_COM_PATH"
        [IMS_FELLO_COM_PATH]="git clone git@github.com:felloco/fc-inventory.git $IMS_FELLO_COM_PATH"
        [V4_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-ims.git $V4_FELLO_COM_PATH"
        [ARAMARK_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-aramark.git $ARAMARK_FELLO_COM_PATH"
        [EVENTBRITE_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-eventbrite.git $EVENTBRITE_FELLO_COM_PATH"
        [FELLO_COM_PATH]="git clone git@github.com:felloco/fello-new.git $FELLO_COM_PATH"
        [GIVESMART_FELLO_COM_PATH]="git clone git@github.com:felloco/fc-community-brands.git $GIVESMART_FELLO_COM_PATH"
        [LEVY_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-levy.git $LEVY_FELLO_COM_PATH"
        [MOBILECAUSE_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-mobile-cause.git $MOBILECAUSE_FELLO_COM_PATH"
        [SHOPIFY_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-shopify.git $SHOPIFY_FELLO_COM_PATH"
        [SHOPIFYCA_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-shopifyca.git $SHOPIFYCA_FELLO_COM_PATH"
        [SQURE_FELLO_COM_PATH]="git clone git@github.com:felloco/fc-square.git $SQURE_FELLO_COM_PATH"
        [SQURECA_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-square-ca.git $SQURECA_FELLO_COM_PATH"
        [TASSEL_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-marching-order.git $TASSEL_FELLO_COM_PATH"
        [TASSELCA_FELLO_COM_PATH]="git clone git@github.com:felloco/fello-marching-order-ca.git $TASSELCA_FELLO_COM_PATH"
    )

    for var in "${!repo_paths[@]}"; do
        path="${repo_paths[$var]}"
        if [ ! -d "$path" ]; then
            echo "⏳ $path does not exist. Cloning..."
            eval "${clone_cmds[$var]}"
        else
            echo "✅ $path exists."
        fi
    done
}

setup_fello_project