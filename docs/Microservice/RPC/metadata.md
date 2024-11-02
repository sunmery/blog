
服务端grpc读取http请求的metadata
```go
package gapi

import (
	"golang.org/x/net/context"
	"google.golang.org/grpc/metadata"
	"log"
	"simple_bank/constants"
)

type Metadata struct {
	UserAgent string
	ClientIP  string
}

func (s *Server) extractMetadata(ctx context.Context) *Metadata {
	mtdt := &Metadata{}

	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		log.Printf("Failed to extract metadata from context")
	}

	log.Printf("metadata from incoming context: %+v\n", md)

	if userAgents := md.Get(constants.GRPCGATEWAYUSERAGENT); len(userAgents) > 0 {
		mtdt.UserAgent = userAgents[0]
	}
	if clientIPs := md.Get(constants.XFORWARDEDFOR); len(clientIPs) > 0 {
		mtdt.ClientIP = clientIPs[0]
	}
	return mtdt
}

```
