params.input_dir = "files"

Channel.fromPath("${params.input_dir}/*")
.set { input_files }

process build_check_file_list {
    // check the list of input files to determine which should be processed
    echo true
    input:
    file(items: "*") from input_files.collect()

    output:
    file("${output_file_csv}") into checked_file_list

    script:
    input_file_list = 'files.txt'
    output_file_csv = "output_list.csv"
    """
    # save all the files to a list; might be longer than CLI supported command length
    # saves basenames only
    echo '${items.join('\n')}' > "${input_file_list}"

    check_file_list.py "${input_file_list}" "${output_file_csv}"
    """
}

// read the items for processing from the .csv file
checked_file_list.splitCsv()
.map { items ->
    def filename = items[0]
    def filepath = file(items[1]) // should be the same as the original filepath

    return([ filename, filepath ])
}
.set { checked_files }

process do_thing_with_file {
    // put your custom file handling code here
    tag "${original_filename}"

    input:
    set val(original_filename), file(filename) from checked_files

    output:
    set val(original_filename), file(filename), file("${original_filepath_txt}") into processed_files

    script:
    original_filepath_txt = "filepath.txt"
    """
    echo "[do_thing_with_file] ${filename}"

    # save the path to .txt file
    python -c "import os; print(os.path.realpath('${filename}'))" > "${original_filepath_txt}"
    """
}

processed_files.map { original_filename, filename, filepath_txt ->
    // get the original full filepath back out
    def line
    new File("${filepath_txt}").withReader { line = it.readLine() }

    return([original_filename, file(line)])
}
.set { processed_files_updated }

process update_database {
    // update the database to record that the file has been processed
    tag "${original_filename}"

    input:
    set val(original_filename), file(filename) from processed_files_updated

    script:
    """
    add_to_db.py "${filename}"
    """
}
