package app;

sub app {
    return sub {
        my $env = shift;
        my $path_info = $env->{PATH_INFO};
        my $query_string = $env->{QUERY_STRING};
        return dispatch($path_info, $query_string);
    }
}

sub route {
    return [
        [ '/' => root ],
        [ '/hello' => hello ],
        [ '/api' => api ],
    ];
}

sub root {
    my ($param) = @_;
    return [ 200, [ 'Content-Type' => 'text/plain' ], ["Hello, It's PSGI!"] ];
}

sub hello {
    my ($param) = @_;
    my $name = $param->{name} || 'Someone';
    return [ 200, [ 'Content-Type' => 'text/plain; charset=UTF-8' ], ["Hello! $name!!"] ];
}

sub api {
    my ($param) = @_;
    my $message = $param->{message} || "";
    return [
        200,
        [ 'Content-Type' => 'application/json' ],
        [ "{ message: \"$message\" }" ]
    ];
}

sub not_found {
    return [
        404,
        ['Content-Type' => 'text/plain'],
        ['Not Found']
    ];
}

sub dispatch {
    my ($path, $query) = @_;
    my $param = query_param($query);
    if ($path eq '/') {
        return root($param);
    }
    if ($path eq '/hello' ) {
        return hello($param);
    }
    if ($path eq '/api' ) {
        return api($param);
    }
    return not_found();
}

sub query_param {
    my ($query_string) = @_;
    for my $kv (split('&', $query_string)) {
        my ($k, $v)  = split('=', $kv);
        $param->{$k} = $v;
    }
    return $param;
}

# For Cloudflare Workers:

sub listener {
    my ($event) = @_;
    my $req = $event->request;
    my $resp = handleRequest($req);
    $event->respondWith($resp);
}

sub handleRequest {
    my ($req) = @_;

    # URL is JavaScript Object
    my $url = URL->new($req->url);
    my $query_string = $url->search;
    $query_string =~ s!^\?!!;

    my $env = { PATH_INFO => $url->pathname, QUERY_STRING => $query_string };
    # Dispatch PSGI app
    my $psgi = app->($env);
    my $msg = $psgi->[2][0];
    my $status = $psgi->[0];

    # Headers is JavaScript Object
    my $headers = Headers->new();
    my $key;
    for my $v ( @{ $psgi->[1] } ) {
        if ($key) {
            $headers->append($key, $v);
            $key = undef;
        }
        else {
            $key = $v;
        }
    }

    # Response is JavaScript Object
    my $res = Response->new(
        $msg,
        {
            status  => 200,
            headers => $headers
        }
    );

    return $res;
}

1;
