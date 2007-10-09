package vjde.completion;


public class PackageCompletion {
    public static void main(String[] args) {
            if ( args.length < 1 ) {
                    System.out.println("<classpath> [package-name]");
		    return;
            }
            //Package[] pkgs = Package.getPackages();
            //ClassLoader l  = new DynamicClassLoader(args[0]);
	    String p = args.length>=1?args[0]:"";
	    System.out.println(p);
            String[] names = new DynamicClassLoader(p).getPackageNames();
            //for ( String n : names ) {
            for ( int i = 0 ; i < names.length ; i++) { //String n : names ) {
                    System.out.println(names[i]);
            }
            /*
            Package[] pkgs = new DynamicClassLoader(args[0]).getPackages();
            for ( Package p : pkgs) {
                    if (p.getName().contains("javax."))
                        System.out.println(p.getName());
                    Annotation[] ans = p.getAnnotations();
                    for ( Annotation an : ans) {
                            System.out.println("\t"+an);
                    }
            }
            */
    }
}
