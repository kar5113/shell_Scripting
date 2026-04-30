 #!/bin/bash
 set -euo pipefail

        # Required secret: AccessToken (PAT) must be configured in pipeline variables as secret
        if [ -z "$(PAT)" ]; then
          echo "ERROR: pipeline variable 'AccessToken' is not set. Mark it as secret in pipeline settings." >&2
          exit 1
        fi

        ORG="$(org)"
        PROJECT="$(project)"
        PAT="$(PAT)"
        START_DATE="$( echo $(startDate) | sed 's/ /T/')"
        END_DATE="$( echo $(endDate) | sed 's/ /T/')"


        # Output paths: write the input list into artifact staging inputs folder so later stages can download it
        ARTIFACT_ROOT="$(Build.ArtifactStagingDirectory)/inputs"
        echo "$(Build.ArtifactStagingDirectory)"
        mkdir -p "$ARTIFACT_ROOT"

        INPUT_LIST_FILE="$ARTIFACT_ROOT/$(INPUT_LIST_REL)"
        # create/clear the input file
        : > "$INPUT_LIST_FILE"

        # Auth header
       
        AUTH_HEADER="Authorization: Bearer $PAT"

        echo "Fetching test runs from $ORG/$PROJECT between ${{ parameters.startDate }} and $(endDate)"
        RUNS_URL="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/runs?minLastUpdatedDate=${{ parameters.startDate }}&maxLastUpdatedDate=${{ parameters.endDate }}&api-version=7.1"
        echo $RUNS_URL

        runs_json=$(curl -sS -H "$AUTH_HEADER" "$RUNS_URL" || true)

        echo "$runs_json[@]"

        # helper: extract all id values (numbers or quoted strings) from a JSON blob
        extract_ids() {
          # returns one id per line
          echo "$1" | grep -o '"id"[[:space:]]*:[[:space:]]*[^,}\]]*' | sed -E 's/.*:[[:space:]]*"?([^\"]+)"?.*/\1/' || true
        }

        # helper: extract all fileName values from a JSON blob (one per line)
        extract_filenames() {
          echo "$1" | grep -o '"fileName"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' || true
        }

        # Read run ids into array (preserve lines with readarray)
        readarray -t run_ids < <(extract_ids "$runs_json")

        echo "${run_ids[0]}"

         for runId in "${run_ids[@]:-}"; do
           # skip empty
           if [ -z "${runId:-}" ]; then
             continue
           fi
           echo "Processing Run ID: $runId"
           runFolder="$ARTIFACT_ROOT/Run_$runId"
           mkdir -p "$runFolder"

           RESULTS_URL="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/results?api-version=7.1"
           results_json=$(curl -sS -H "$AUTH_HEADER" "$RESULTS_URL" || true)
           readarray -t result_ids < <(extract_ids "$results_json")

           for resultId in "${result_ids[@]:-}"; do
             if [ -z "${resultId:-}" ]; then
               continue
             fi
             echo "  Processing Result ID: $resultId"
             resultFolder="$runFolder/Result_$resultId"
             mkdir -p "$resultFolder"

             # RESULT-LEVEL ATTACHMENTS
             RES_ATT_URL="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/Results/${resultId}/attachments?api-version=7.1"
             res_att_json=$(curl -sS -H "$AUTH_HEADER" "$RES_ATT_URL" || true)

             # build parallel arrays: ids and fileNames (order preserved by grep)
             readarray -t att_ids < <(echo "$res_att_json" | extract_ids)
             readarray -t file_names < <(echo "$res_att_json" | extract_filenames)

             # iterate by index (len of att_ids) using bash-native indices
             for i in "${!att_ids[@]}"; do
             # iterate by index (len of att_ids)
             len=${#att_ids[@]}
             for i in $(seq 0 $((len - 1)) 2>/dev/null); do
             # iterate by index (len of att_ids)
             len=${#att_ids[@]}
             for i in $(seq 0 $((len - 1)) 2>/dev/null); do
               attId="${att_ids[i]}"
               fileName="${file_names[i]:-}"

               # skip missing id
               if [ -z "${attId:-}" ] || [ "${attId}" = "null" ]; then
                 continue
               fi

               # detect html by extension (case-insensitive)
               if printf "%s" "$fileName" | grep -Ei '\\.(html?|HTML?)$' >/dev/null 2>&1; then
                 echo "$resultFolder/$fileName" >> "$INPUT_LIST_FILE"
                 echo "    Found HTML (result-level): $fileName"
               fi

               downloadUrl="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/Results/${resultId}/attachments/${attId}?api-version=7.1"
               outPath="$resultFolder/$fileName"
               echo "    Downloading attachment (result-level): $fileName"
               if ! curl -sS -H "$AUTH_HEADER" -o "$outPath" "$downloadUrl"; then
                 echo "    Result-level download failed for $fileName" >&2
               fi
             done

             # ITERATION-LEVEL ATTACHMENTS
             ITER_URL="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/Results/${resultId}/iterations?api-version=7.1"
             iter_json=$(curl -sS -H "$AUTH_HEADER" "$ITER_URL" || true)
             readarray -t iter_ids < <(extract_ids "$iter_json")

             for iterId in "${iter_ids[@]:-}"; do
               if [ -z "${iterId:-}" ]; then
                 continue
               fi
               echo "    Iteration: $iterId"
               ITER_ATT_URL="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/Results/${resultId}/iterations/${iterId}/attachments?api-version=7.1"
               iter_att_json=$(curl -sS -H "$AUTH_HEADER" "$ITER_ATT_URL" || true)

               readarray -t it_att_ids < <(echo "$iter_att_json" | extract_ids)
               readarray -t it_file_names < <(echo "$iter_att_json" | extract_filenames)
               # iterate over iteration-level attachment indices safely
               for j in "${!it_att_ids[@]}"; do

                ilen=${#it_att_ids[@]}
                for j in $(seq 0 $((ilen - 1)) 2>/dev/null); do

               ilen=${#it_att_ids[@]}
               for j in $(seq 0 $((ilen - 1)) 2>/dev/null); do
                 attId="${it_att_ids[j]}"
                 fileName="${it_file_names[j]:-}"
                 if [ -z "${attId:-}" ] || [ "${attId}" = "null" ]; then
                   continue
                 fi

                 if printf "%s" "$fileName" | grep -Ei '\\.(html?|HTML?)$' >/dev/null 2>&1; then
                   echo "$resultFolder/$fileName" >> "$INPUT_LIST_FILE"
                   echo "      Found HTML (iteration-level): $fileName"
                 fi

                 downloadUrl="https://dev.azure.com/${ORG}/${PROJECT}/_apis/test/Runs/${runId}/Results/${resultId}/iterations/${iterId}/attachments/${attId}?api-version=7.1"
                 outPath="$resultFolder/$fileName"
                 echo "      Downloading attachment (iteration-level): $fileName"
                 if ! curl -sS -H "$AUTH_HEADER" -o "$outPath" "$downloadUrl"; then
                   echo "      ERROR downloading: $fileName" >&2
                 fi
               done
             done

           done
         done

        echo "All downloads attempted. Input list saved to: $INPUT_LIST_FILE"