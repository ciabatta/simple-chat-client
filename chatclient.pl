#!usr/bin/perl
use strict;
use warnings;
use IO::Socket;
use Gtk2 -init;
use Constant TRUE => 1;
use Constant FALSE=> 0;

my $window1 = Gtk2::Window->new('toplevel');
	$window1->set_title("Connections.");
	$window1->set_border_width(5);
	$window1->signal_connect('delete_event' => sub{ exit;});
my $VBox1 = Gtk2::VBox->new;
my $infoframe = Gtk2::Frame->new();
	$infoframe->set_label("Enter server creation information here.");
	$infoframe->set_border_width(4);
my $infotable = Gtk2::Table->new(2, 2, 0);
my $portenter = Gtk2::Entry->new();
	$portenter->set_text("Port number.");
	$portenter->set_editable(1);
my $nameentry = Gtk2::Entry->new();
	$nameentry->set_text("Chat name!");
	$nameentry->set_editable(1);
my $createserverbutton = Gtk2::Button->new();
	$createserverbutton->set_label("Launch Server");
	$createserverbutton->signal_connect(clicked => sub{
			my $portinput = $portenter->get_text;
			my $nameinput = $nameentry->get_text;
			serverchatwindow($portinput, $nameinput);
			exit;
		}
	);
my $clientframe = Gtk2::Frame->new();
	$clientframe->set_border_width(4);
	$clientframe->set_label("Enter server connection information here.");
my $clienttable = Gtk2::Table->new(2, 2, 0);
my $clientaddressentry = Gtk2::Entry->new();
	$clientaddressentry->set_text("Server address.");
my $clientportentry = Gtk2::Entry->new();
	$clientportentry->set_text("Server port.");
my $clientnameentry = Gtk2::Entry->new();
	$clientnameentry->set_text("Chat name!");
my $clientconnectbutton = Gtk2::Button->new();
	$clientconnectbutton->set_label("Connect.");
	$clientconnectbutton->signal_connect(clicked => sub{
				my $clientaddress = $clientaddressentry->get_text;
			my $clientport = $clientportentry->get_text;
			my $clientname = $clientnameentry->get_text;
			clientchatwindow($clientaddress, $clientport, $clientname);
			exit;
		}
	);
$infotable->attach($portenter, 0, 5, 0, 3, 'fill', 'fill', 0, 0);
$infotable->attach($nameentry, 5, 10, 0, 3, 'fill', 'fill', 0, 0);
$infotable->attach($createserverbutton, 0, 1, 3, 6, 'shrink', 'shrink', 0, 0);
$clienttable->attach($clientaddressentry, 0, 5, 0, 3, 'fill', 'fill', 0, 0);
$clienttable->attach($clientportentry, 5, 10, 0, 3, 'fill', 'fill', 0, 0);
$clienttable->attach($clientnameentry, 0, 5, 3, 6, 'fill', 'fill', 0, 0);
$clienttable->attach($clientconnectbutton, 5, 10, 3, 6, 'shrink', 'shrink', 0, 0);
$infoframe->add($infotable);
$clientframe->add($clienttable);
$VBox1->add($infoframe);
$VBox1->add($clientframe);
$window1->add($VBox1);
$window1->show_all;
Gtk2->main;

sub clientchatwindow {
	my ($address, $port, $name) = @_;
	my $window = Gtk2::Window->new();
		$window->set_title("Chat program.");
		$window->set_border_width(5);
	my $scrolledwindow = Gtk2::ScrolledWindow->new(undef, undef);
		$scrolledwindow->set_policy('automatic', 'automatic');
		$scrolledwindow->set_size_request(300, 150);
		$scrolledwindow->set_border_width(5);
	my $swsend = Gtk2::ScrolledWindow->new(undef, undef);
		$swsend->set_policy('automatic', 'automatic');
		$swsend->set_size_request(300, 75);
		$swsend->set_border_width(5);
	my $VBox = Gtk2::VBox->new();
	my $textview = Gtk2::TextView->new();
	my $textbuffer = Gtk2::TextBuffer->new();
		$textview->set_buffer($textbuffer);
		$textview->set_editable(0);
		$textview->set_wrap_mode('char');
		my $statusiter = $textbuffer->get_start_iter;
	my $textframe = Gtk2::Frame->new();
		$textframe->set_border_width(4);
		$textframe->set_label("Chat.");
	my $sendtextview = Gtk2::TextView->new();
	my $sendtextbuffer = Gtk2::TextBuffer->new();
		$sendtextview->set_buffer($sendtextbuffer);
		$sendtextview->set_editable(1);
		$sendtextview->set_wrap_mode('char');
	my $sendtextframe = Gtk2::Frame->new();
		$sendtextframe->set_label("Text to send.");
		$sendtextframe->set_border_width(4);
	my $chatbuttontable = Gtk2::Table->new(2, 2, 0);
	my $chatbutton = Gtk2::Button->new();
		$chatbutton->set_label("Send");
		$chatbutton->signal_connect(clicked => sub{
			my $startiter = $sendtextbuffer->get_start_iter;
			my $enditer = $sendtextbuffer->get_end_iter;
			my $texttosend = $sendtextbuffer->get_text($startiter, $enditer, 1);
			my $insertiter = $textbuffer->get_end_iter;
				$textbuffer->insert($insertiter, "\n$name: $texttosend\n");
			my $messagesend = ("\n$name: $texttosend\n");
			clientsendsub($messagesend);
			}
		);
	$scrolledwindow->add($textview);
	$textframe->add($scrolledwindow);
	$swsend->add($sendtextview);
	$sendtextframe->add($swsend);
	$chatbuttontable->attach($chatbutton, 0, 3, 0, 1, 'fill', 'fill', 0, 0);
	$VBox->add($textframe);
	$VBox->add($sendtextframe);
	$VBox->add($chatbuttontable);
	$window->add($VBox);
	$window->show_all;
	my $client = new IO::Socket::INET {
		PeerHost => "$address",
		PeerPort => "$port",
		Proto => "tcp",
	};
	die $textbuffer->insert($statusiter, "Could not connect to server at $address on port $port, $name!\n");
	$textbuffer->insert($statusiter, "Connected to the server at $address on port $port!\n");
	while (my $server = <$client>) {
		my $enditer = $textbuffer->get_end_iter;
		$textbuffer->insert($enditer, "$server");
	}
	sub clientsendsub {
		my ($message) = @_;
		print $client "$message\r\r";
		$client->flush;
	}
	close $client; 
	$textbuffer->insert($statusiter, "Connection closed!");
}

sub serverchatwindow {
	my ($port, $name) = @_;
	my $window = Gtk2::Window->new();
		$window->set_title("Chat program.");
		$window->set_border_width(5);
	my $scrolledwindow = Gtk2::ScrolledWindow->new(undef, undef);
		$scrolledwindow->set_policy('automatic', 'automatic');
		$scrolledwindow->set_size_request(300, 150);
		$scrolledwindow->set_border_width(5);
	my $swsend = Gtk2::ScrolledWindow->new(undef, undef);
		$swsend->set_policy('automatic', 'automatic');
		$swsend->set_size_request(300, 75);
		$swsend->set_border_width(5);
	my $VBox = Gtk2::VBox->new();
	my $textview = Gtk2::TextView->new();
	my $textbuffer = Gtk2::TextBuffer->new();
		$textview->set_buffer($textbuffer);
		$textview->set_editable(0);
		$textview->set_wrap_mode('char');
		my $statusiter = $textbuffer->get_start_iter;
	my $textframe = Gtk2::Frame->new();
		$textframe->set_border_width(4);
		$textframe->set_label("Chat.");
	my $sendtextview = Gtk2::TextView->new();
	my $sendtextbuffer = Gtk2::TextBuffer->new();
		$sendtextview->set_buffer($sendtextbuffer);
		$sendtextview->set_editable(1);
		$sendtextview->set_wrap_mode('char');
	my $sendtextframe = Gtk2::Frame->new();
		$sendtextframe->set_label("Text to send.");
		$sendtextframe->set_border_width(4);
	my $chatbuttontable = Gtk2::Table->new(2, 2, 0);
	my $chatbutton = Gtk2::Button->new();
		$chatbutton->set_label("Send");
		$chatbutton->signal_connect(clicked => sub{
			my $startiter = $sendtextbuffer->get_start_iter;
			my $enditer = $sendtextbuffer->get_end_iter;
			my $texttosend = $sendtextbuffer->get_text($startiter, $enditer, 1);
			my $insertiter = $textbuffer->get_end_iter;
				$textbuffer->insert($insertiter, "\n$name: $texttosend\n");
			my $messagesend = "\n$name: $texttosend\n";
			serversendsub($messagesend);
			}
		);
	$scrolledwindow->add($textview);
	$textframe->add($scrolledwindow);
	$swsend->add($sendtextview);
	$sendtextframe->add($swsend);
	$chatbuttontable->attach($chatbutton, 0, 3, 0, 1, 'fill', 'fill', 0, 0);
	$VBox->add($textframe);
	$VBox->add($sendtextframe);
	$VBox->add($chatbuttontable);
	$window->add($VBox);
	$window->show_all;
	my $server = new IO::Socket::INET (
		LocalPort => "$port",
		Type => SOCK_STREAM,
		Reuse => 1,
		Listen => 10,
	);
	die $textbuffer->insert($statusiter, "Could not create server on port $port, $name!\n");
	$textbuffer->insert($statusiter, "Server created, listening on port $port, $name.\n");
	my $client;
	while ($client = $server->accept()) {
		$client->autoflush(1);
		my $line = <$client>;
		my $enditer = $textbuffer->get_end_iter;
		$textbuffer->insert($enditer, "$client");
	}
	sub serversendsub {
		my $message = @_;
		print $server "$message\r\r";
		$server->flush();
	}
	close $server;
	$textbuffer->insert($statusiter, "Connection closed!");
}

1;






