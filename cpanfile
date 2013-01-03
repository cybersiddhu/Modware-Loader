requires "Bio::Chado::Schema" => "0.20000";
requires "Bio::GFF3::LowLevel" => "1.5";
requires "BioPortal::WebService" => "v1.0.0";
requires "DBD::Oracle" => "1.52";
requires "File::Find::Rule" => "0.32";
requires "Log::Log4perl" => "1.40";
requires "MooseX::App::Cmd" => "0.06";
requires "MooseX::Attribute::Dependent" => "v1.1.2";
requires "MooseX::ConfigFromFile" => "0.02";
requires "MooseX::Getopt" => "0.50";
requires "Tie::Cache" => "0.19";
requires "perl" => "5.010";
recommends "Child" => "0.009";
recommends "Email::Sender::Simple" => "0.102370";
recommends "Email::Simple" => "2.10";
recommends "Email::Valid" => "0.184";
recommends "GOBO" => "0.03";
recommends "Log::Dispatchouli" => "2.005";
recommends "Modware" => "0.001";
recommends "Spreadsheet::WriteExcel" => "2.37";
recommends "Text::TablularDisplay" => "1.33";
recommends "XML::LibXML" => "1.70";
recommends "XML::Simple" => "2.18";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "Test::More" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "version" => "0.9901";
};
