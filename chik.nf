params.options = 'sample.tsv'

options = Channel.fromPath(params.options).splitCsv(header: true).map { row ->
    def lbl = row['key_name']
    def val = row['value']
    // println "-- full row: ${row}"
    return [ lbl, val]
}

options.subscribe { println "value ${it}" }

process nanoplot {
    input:
        options
    script:
    """
    nanoplot_wrapper.py -p options
    """
}

workflow {
    nanoplot
}
