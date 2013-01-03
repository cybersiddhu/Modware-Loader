requires "Bio::Chado::Schema" => "0.09000";
requires "Bio::GFF3" => "0.7";
requires "BioPortal::WebService" => "v1.0.0";
requires "File::Find::Rule" => "0.32";
requires "Log::Log4perl" => "1.38";
requires "MooseX::App::Cmd" => "0.06";
requires "MooseX::ConfigFromFile" => "0.02";
requires "MooseX::Getopt" => "0.33";
requires "Throwable" => "0.102080";
requires "Tie::Cache" => "0.19";
requires "perl" => "5.010";
recommends "Child" => "0.009";
recommends "Email::Sender::Simple" => "0.102370";
recommends "Email::Simple" => "2.10";
recommends "Email::Valid" => "0.184";
recommends "GOBO" => "0.03";
recommends "Log::Dispatchouli" => "2.005";
recommends "Log::Log4perl" => "1.30";
recommends "Modware" => "0.001";
recommends "MooseX::Attribute::Dependent" => "v1.1.2";
recommends "Spreadsheet::WriteExcel" => "2.37";
recommends "Text::TablularDisplay" => "1.33";
recommends "XML::LibXML" => "1.70";
recommends "XML::Simple" => "2.18";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};
