package vjde.completion;
public class PackageClasses {
	public static void main(String[] args) {
		if ( args.length < 2 ) {
			return ;
		}
		String[] names = new DynamicClassLoader(args[0]).getClassNames(args[1]);
		for ( int i = 0 ; i < names.length ; i++) {
			System.out.println(names[i]);
		}
	}
}
