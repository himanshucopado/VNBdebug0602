*** Settings ***

Library                   RetryFailed                 global_retries=2
Documentation             New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                   QForce
Library                   FakerLibrary
Library                   OperatingSystem
# Library                 ../Library/GitOperations.py
Library                   ../Library/GitOperations.py
Library                   Process
Suite Setup               Open Browser                about:blank                 chrome
Suite Teardown            Close All Browsers

*** Variables ***
${git_branch}             main

*** Keywords ***
Save Account Number To Daily File
    # [Arguments]           ${account_number}
    [Documentation]       Creates or appends the Account Number to a daily dated text file
    ...                   in the Data folder at root: ${EXECDIR}/Data/YYYY-MM-DD.txt
    ...                   First run of the day creates the file, every subsequent run appends.

    # Suite-wide scope

    # ${account_number}=                              Set Suite Variable          ${account_number}    12345678
    ${account_number}     Set Variable                12345678
    Set Suite Variable    ${account_number}
    Log To Console        ${account_number}



    # Get today's date using Python built-in — no DateTime library needed
    ${today}=             Evaluate                    __import__('datetime').datetime.now().strftime('%Y-%m-%d')
    Log To Console        ${today}

    # Build the full file path pointing to the Data folder you created at root
    ${file_path}=         Set Variable                ${CURDIR}/../Data/${today}.txt
    
    Log To Console        ${file_path}

    # Check if today's file already exists
    ${file_exists}=       Run Keyword And Return Status                           File Should Exist    ${file_path}
    Log To Console        ${file_exists}
    Log To Console        ${account_number}
    # If file exists → append account number on a new line
    # If file does not exist → create it with account number as first line
    #Evaluate             open(r'${file_path}', 'a', encoding='utf-8').write('${account_number}' + '\n')
    IF                    ${file_exists}
        Append To File    ${file_path}                ${account_number}${\n}      encoding=UTF-8
    ELSE
        Create File       ${file_path}                ${account_number}${\n}      encoding=UTF-8
    END
    ${filecontent}        GetFile                     ${file_path}
    Log To Console        ${filecontent}
    Log                   Account number [${account_number}] saved to: ${file_path}
    logtoconsole          Account number [${account_number}] saved to: ${file_path}
    logtoconsole          ${git_branch}

    # Save Text Document
    #                     [Arguments]                 ${file_path}
    #                     [Documentation]             Commits and pushes the given file to the current Git branch.
    # Replace the Log below with a Run Process Git commit if automation of Git push is needed
    # Log                 Saving file to branch: ${git_branch} — path: ${file_path}
    Commit And Push       ${file_path}                ${git_branch}

    # Log                 Using repo path: ${REPO_DIR}
    # Commit And Push     ${file_path}                Sidtest

    # Run Process         git                         add                         ${file_path}      cwd=${git_branch}

    # # Commit
    # Run Process         git                         commit                      -m                cwd=${git_branch}

    # # Push
    # Run Process         git                         push                        cwd=${git_branch}