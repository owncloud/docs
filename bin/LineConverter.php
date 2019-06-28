<?php

declare(strict_types=1);

namespace LineConverter;

/**
 * Class LineConverter
 *
 * Usage example:
 *
 * include 'vendor/autoload.php';
 *
 * use LineConverter\LineConverter;
 *
 * while ($line = fgets(STDIN)) {
 *   print LineConverter::convertLine($line);
 * }
 *
 * @package LineConverter
 */
final class LineConverter
{
    const LINE_PATTERN = '/(\*+)( xref:)(.*)(\[.*\])/' ;

    /**
     * Convert a line from Antora nav to asciidoctor-pdf format
     *
     * For example, the function would change "*** xref:bugtracker/triaging.adoc[Bug Triaging]"
     * to "include::modules/bugtracker/triaging.adoc[leveloffset=+3]"
     *
     * @param string $line
     * @return string
     * @see https://docs.antora.org/antora/2.0/navigation/link-syntax-and-content/#content
     * @see https://asciidoctor.org/docs/asciidoctor-pdf/
     */
    static public function convertLine(string $line): string
    {
        return preg_replace_callback(
            self::LINE_PATTERN,
            function ($matches) {
                return sprintf('%s%s%s',
                    'include::{module_base_path}',
                    $matches[3],
                    sprintf('[leveloffset=+%s]', strlen($matches[1]))
                );
            },
            $line
        );
    }
}
